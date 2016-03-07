require 'stripe_mock'

include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do |config|

  config.before(:each) do
    StripeMock.start
    FactoryGirl.reload
  end

  config.after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end
end

# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
feature 'Sign Up', :devise, type: :controller, js: true do

  before do
    CreatePlanService.new.call
  end

  # Scenario: Visitor can sign up with valid email address and password
  #   Given I am not signed in
  #   When I sign up with a valid email address and password
  #   Then I see a successful sign up message
  scenario 'visitor can sign up as a silver subscriber' do
    pending 'signups need more work'
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'visitor can sign up as a gold subscriber' do
    pending 'signups need more work'
    visit '/users/sign_up?plan=gold'
    expect(current_path).to eq '/users/sign_up'
    sign_up_gold
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'visitor can sign up as a platinum subscriber' do
    pending 'signups need more work'
    sign_up_platinum
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  # another system's tests

  # Scenario: Visitor can sign up with valid email address and password
  #   Given I am not signed in
  #   When I sign up with a valid email address and password
  #   Then I see a successful sign up message
  scenario 'visitor can sign up with valid email address and password' do
    pending 'needs work, Devise message not showing on page redirected to, yet shows on edit!'
    sign_up_with('test@example.com', 'please123', 'please123')
    txts = [I18n.t('devise.registrations.signed_up'), I18n.t('devise.registrations.signed_up_but_unconfirmed')]
    expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
  end

  # Scenario: Visitor cannot sign up with invalid email address
  #   Given I am not signed in
  #   When I sign up with an invalid email address
  #   Then I see an invalid email message
  scenario 'visitor cannot sign up with invalid email address' do
    sign_up_with('bogus', 'please123', 'please123')
    expect(page).to have_content ' Please review the problems below'
    expect(page).to have_content ' Email is invalid'
    expect(page).to have_content ' 8 characters minimum'
    expect(page).to have_content ' Already have an account ? Log in'
  end
end
