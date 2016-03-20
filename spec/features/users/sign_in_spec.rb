# frozen_string_literal: true
require 'stripe_mock'
include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!

# Feature: Sign in
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
feature 'Sign in', :devise, live: true, js: true do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
    FactoryGirl.reload
    @user = FactoryGirl.build(:user, email: 'admin@example.com')
    # @user.role = 'admin'
    @user.add_role 'admin'
    @user.save!
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'can sign in with valid credentials' do
    user = FactoryGirl.build(:user)
    # user.role = 'admin'
    user.add_role('admin')
    user.save!
    visit new_user_session_path
    sign_in(user.email, user.password)
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    visit '/users'
    expect(current_path).to eq '/users'
  end

  # Scenario: Silver User can sign in with valid credentials
  #   Given I exist as a silver user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'can sign in with valid silver credentials' do
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
    expect(charge.customer).to eq customer.id

    customer = Stripe::Customer.retrieve(customer.id)
    user = FactoryGirl.build(:user, email: 'index@example.com')
    user.customer_id = customer.id
    user.last_4_digits = '4242'
    # user.role = 'silver'
    user.add_role 'silver'
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
  end

  # Scenario: Gold User can sign in with valid credentials
  #   Given I exist as a gold user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'gold user can sign in with valid credentials' do
    plan = stripe_helper.create_plan(id: 'gold', amount: 1900)
    expect(plan.id).to eq 'gold'

    Stripe::Plan.retrieve(plan.id)
    expect(plan.amount).to eq 1900

    card_token = StripeMock.generate_card_token(
      last4: '1123',
      exp_month: 9,
      exp_year: 2019
    )
    customer = Stripe::Customer.create(
      email: 'index@example.com',
      source: card_token,
      description: 'a customer description'
    )
    charge = Stripe::Charge.create({
                                     amount: 1900,
                                     currency: 'usd',
                                     interval: 'month',
                                     customer: customer.id,
                                     description: 'Charge for index@example.com'
                                   },
                                     idempotency_key: '95ea4310438306ch'
                                  )
    expect(charge.customer).to eq customer.id

    customer = Stripe::Customer.retrieve(customer.id)
    @user = FactoryGirl.build(:user, email: 'index@example.com')
    @user.customer_id = customer.id
    # @user.role = 'gold'
    @user.add_role 'gold'
    @user.save!
    expect(@user.customer_id).to eq customer.id

    visit '/users/sign_in'
    expect(current_path).to eq '/users/sign_in'

    fill_in 'Email', with: 'index@example.com'
    fill_in 'Password', with: 'changemenow'
    click_on 'Sign in'
    expect(current_path).to eq '/content/gold'
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    expect(current_path).to eq '/content/gold'
  end

  scenario 'signed in user cannot visit /users/index page' do
    customer = Stripe::Customer.create(id: 'test_customer')
    user = FactoryGirl.build(:user)
    user.customer_id = customer.id
    user.save!
    visit new_user_session_path
    login_as user
    visit '/users/index'
    expect(current_path).not_to eq '/users'
    expect(current_path).to eq '/home'
  end

  # Scenario: User not registered cannot sign in
  #   Given I do not exist as a user
  #   When I sign in with valid credentials
  #   Then I see an invalid credentials message
  scenario ' cannot sign in with valid credentials, if not registered' do
    sign_in('test@example.com', 'changeme')
    expect(current_path).to eq '/users/sign_in'
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  scenario ' cannot sign in with invalid credentials' do
    user = FactoryGirl.create(:user)
    expect(user.persisted?). to eq true
    visit new_user_session_path
    expect(current_path).to eq '/users/sign_in'

    sign_in('tester@example.com', 'notmypassword')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  # Scenario: User cannot sign in with wrong email
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'cannot sign in with wrong email' do
    visit new_user_session_path
    sign_in('wrong@example.com', 'user.password')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  # Scenario: user2 cannot sign in with incorrect email : version two
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'cannot sign in with invalid email' do
    user = FactoryGirl.build(:user)
    # user.role = 'admin'
    user.add_role 'admin'
    user.save!
    sign_in('invalid@email.com', user.password)
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  # Scenario: User cannot sign in with invalid password : version 1
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with an invalid password
  #   Then I see an invalid password message
  scenario 'user cannot sign in with invalid password' do
    user = FactoryGirl.build(:user)
    # user.role = 'admin'
    user.add_role 'admin'
    user.save!
    visit new_user_session_path
    sign_in(user.email, 'invalidpass')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  scenario 'signed in user cannot sign in twice' do
    card_token = StripeMock.generate_card_token(
      last_4_digits: '4242',
      exp_month: 10,
      exp_year: 2020
    )
    customer = Stripe::Customer.create(
      email: 'chargeitem@example.com',
      description: 'customer creation with card token'
    )
    charge = Stripe::Charge.create({
                                     amount: 900,
                                     currency: 'usd',
                                     interval: 'month',
                                     source: card_token,
                                     description: 'a charge with a specific card'
                                   },
                                     idempotency_key: '95ea4310438306ch'
                                  )
    expect(charge.source.id).to match(/^test_cc/)
    expect(charge.id).to match(/^test_ch/)
    expect(charge.source.object).to eq 'card'
    expect(charge.source.last4).to eq '4242'
    expect(charge.source.brand).to eq 'Visa'
    expect(charge.source.exp_month).to eq 10
    expect(charge.source.exp_year).to eq 2020
    expect(charge.source.name).to eq 'Johnny App'
    expect(charge.source.cvc_check).to eq nil
    expect(charge.description).to eq 'a charge with a specific card'

    @user = FactoryGirl.build(:user)
    @user.customer_id = customer.id
    @user.last_4_digits = '4242'
    # @user.role = 'silver'
    @user.add_role 'silver'
    @user.save!
    expect(customer.id).to eq @user.customer_id
    expect(@user.customer_id).to match(/^test_cus/)
    visit new_user_session_path
    sign_in(@user.email, @user.password)
    expect(current_path).to eq '/content/silver'
    expect(page).to have_content 'Signed in successfully.'

    visit new_user_session_path
    expect(page).to have_content 'You are already signed in.'
  end

  scenario 'GET#show fails because users cannot view the user_path' do
    plan = stripe_helper.create_plan(id: 'gold', amount: 1900)
    expect(plan.id).to eq 'gold'

    Stripe::Plan.retrieve(plan.id)
    expect(plan.amount).to eq 1900

    card_token = StripeMock.generate_card_token(last4: '1123', exp_month: 9, exp_year: 2019)
    customer = Stripe::Customer.create(
      email: 'index@example.com',
      source: card_token,
      description: 'a customer description'
    )
    charge = Stripe::Charge.create({
                                     amount: 1900,
                                     currency: 'usd',
                                     interval: 'month',
                                     customer: customer.id,
                                     description: 'Charge for index@example.com'
                                   },
                                     idempotency_key: '95ea4310438306ch'
                                  )
    expect(charge.customer).to eq customer.id

    customer = Stripe::Customer.retrieve(customer.id)
    @user = FactoryGirl.build(:user,
                               email: 'show@example.com',
                               password: 'changemenow',
                               password_confirmation: 'changemenow'
                             )
    @user.customer_id = customer.id
    @user.last_4_digits = '4242'
    # @user.role = 'gold'
    @user.add_role 'gold'
    @user.save!
    expect(@user.customer_id).to eq customer.id

    visit '/users/sign_in'
    expect(current_path).to eq '/users/sign_in'

    fill_in 'Email', with: 'show@example.com'
    fill_in 'Password', with: 'changemenow'
    click_on 'Sign in'
    expect(current_path).to eq '/content/gold'
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'

    visit '/users/sign_out'
    expect(page).to have_content 'Signed out successfully.'
    expect(current_path).to eq '/'

    login_as @user
    visit users_path
    expect(page).to have_content 'Not authorized as an administrator.'

    visit edit_user_registration_path(@user.id)
    expect(current_path).to eq "/users/edit.#{@user.id}"
    expect(@user.roles.first[:name]).to eq 'gold'
  end
end
