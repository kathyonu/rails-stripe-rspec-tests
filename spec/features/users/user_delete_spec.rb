# frozen_string_literal: true
require 'stripe_mock'
include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!

# Feature: User delete
#   As a user
#   I want to delete my user profile
#   So I can close my account
feature 'User delete', :devise, live: true, js: true do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
    FactoryGirl.reload
    user = FactoryGirl.build(:user, email: 'admin@example.com')
    user.add_role 'admin'
    # user.role = 'admin'
    user.save!
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  # Scenario: User can delete own account
  #   Given I am signed in
  #   When I delete my account
  #   Then I should see an account deleted message
  scenario 'user can delete own account' do
    plan = stripe_helper.create_plan(id: 'silver', amount: 900)
    expect(plan.id).to eq 'silver'

    Stripe::Plan.retrieve(plan.id)
    expect(plan.amount).to eq 900

    card_token = StripeMock.generate_card_token(last4: '1123', exp_month: 9, exp_year: 2019)
    customer = Stripe::Customer.create(
      email: 'index@example.com',
      source: card_token,
      description: 'a customer description'
    )
    charge = Stripe::Charge.create({
                                     amount: 900,
                                     currency: 'usd',
                                     interval: 'month',
                                     customer: customer.id,
                                     description: 'Charge for index@example.com'
                                   },
                                     idempotency_key: '95ea4310438306ch'
                                  )
    expect(charge.amount).to eq 900
    expect(charge.customer).to eq customer.id

    customer = Stripe::Customer.retrieve(customer.id)
    user = FactoryGirl.build(:user, email: 'index@example.com')
    user.customer_id = customer.id
    user.last_4_digits = '4242'
    user.role = 'silver'
    # user.add_role 'silver'
    user.save!
    expect(customer.id).to eq user.customer_id
    expect(user.customer_id).to eq customer.id

    visit '/users/sign_in'
    expect(current_path).to eq '/users/sign_in'

    fill_in 'Email', with: 'index@example.com'
    fill_in 'Password', with: 'changemenow'
    click_on 'Sign in'
    expect(current_path).to eq '/content/silver'
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'

    visit edit_user_registration_path(user)
    expect(current_path).to match(/edit\.\d+/)

    fill_in :user_password, with: 'changme'
    expect(page).to have_selector('.cancel')

    within '.cancel' do
      page.find('div.cancel > a.btn.btn-xs').click
    end
    # LEARNING NOTE : if you break in with a pry binding command,
    # and run below command, you will gain great understanding.
    # puts page.driver.browser.methods

    accept_alert
    # page.driver.browser.switch_to.alert.accept # works
    # page.driver.browser.switch_to.alert.dismiss # fails
    expect(page).to have_content I18n.t 'devise.registrations.destroyed'
  end
end
