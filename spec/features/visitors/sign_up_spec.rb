# spec/features/visitors/sign_up_spec.rb
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
feature 'Sign Up', :devise, type: :features, js: true, live: true do
  scenario 'visitor can sign up as a silver subscriber' do
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver('user4@example.com', 'please124', 'please124')
    expect(page).to have_content 'Welcome! You have signed up successfully.'

    visit '/content/silver'
    expect(current_path).to eq '/content/silver'
  end

  scenario 'visitor can sign up as a gold subscriber' do
    visit '/users/sign_up?plan=gold'
    expect(current_path).to eq '/users/sign_up'
    sign_up_gold('user5@example.com', 'please125', 'please125')
    expect(page).to have_content 'Welcome! You have signed up successfully.'

    visit '/content/gold'
    expect(current_path).to eq '/content/gold'
  end

 scenario 'visitor can sign up as a platinum subscriber' do
    visit '/users/sign_up?plan=platinum'
    expect(current_path).to eq '/users/sign_up'
    sign_up_platinum('user6@example.com', 'please126', 'please126')
    # expect(current_path).to eq '/users/sign_up'
    expect(page).to have_content 'Welcome! You have signed up successfully.'

    visit '/content/platinum'
    expect(current_path).to eq '/content/platinum'
  end

  # another system's tests

  scenario 'visitor can sign up as a board member subscriber' do
    visit '/users/sign_up?plan=board'
    expect(current_path).to eq '/users/sign_up'
    sign_up_board('user5@example.com', 'please125', 'please125')
    expect(page).to have_content 'Welcome! You have signed up successfully.'

    visit '/content/board'
    expect(current_path).to eq '/content/board'
  end

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


  # Scenario: Visitor cannot sign up with invalid email address
  #   Given I am not signed in
  #   When I sign up with an invalid email address
  #   Then I see an invalid email message
  scenario 'visitor cannot sign up with invalid email address' do
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver('', 'please126', 'please126')
    expect(page).to have_content 'Please review the problems below:'
    # expect(page).to have_content '1 error prohibited this user from being saved:'
    expect(page).to have_content "Email can't be blank"
    expect(page).to have_content 'Credit card acceptance is pending.'
  end

  # Scenario: Visitor cannot sign up without password
  #   Given I am not signed in
  #   When I sign up without a password
  #   Then I see a missing password message
  scenario 'visitor cannot sign up without password' do
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver('nopassword@example.com', '', 'please126')
    expect(current_path).to eq '/users/sign_up'
    expect(page).to have_content 'Please review the problems below:'
    # expect(page).to have_content '2 errors prohibited this user from being saved:'
    expect(page).to have_content "Password can't be blank"
    expect(page).to have_content "Password confirmation doesn't match"
    expect(page).to have_content 'Credit card acceptance is pending.'
  end

  # Scenario: Visitor cannot sign up with a short password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  scenario 'visitor cannot sign up with a short password' do
    visit '/users/sign_up?plan=gold'
    expect(current_path).to eq '/users/sign_up'
    sign_up_gold('shortpassword@example.com', 'pleas', 'pleas123')
    expect(page).to have_content 'Please review the problems below:'
    # expect(page).to have_content '3 errors prohibited this user from being saved:'
    expect(page).to have_content 'Password is too short'
    expect(page).to have_content "Password confirmation doesn't match Password"
    expect(page).to have_content 'Credit card acceptance is pending.'
  end

  # Scenario: Visitor cannot sign up without password confirmation
  #   Given I am not signed in
  #   When I sign up without a password confirmation
  #   Then I see a missing password confirmation message
  scenario 'visitor cannot sign up without password confirmation' do
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver('shortpassword@example.com', 'please123', '')
    expect(page).to have_content 'Please review the problems below:'
    # expect(page).to have_content '1 error prohibited this user from being saved:'
    expect(page).to have_content "Password confirmation doesn't match Password"
    expect(page).to have_content 'Credit card acceptance is pending.'
  end

  # Scenario: Visitor cannot sign up with mismatched password and confirmation
  # Given I am not signed in
  # When I sign up with a mismatched password confirmation
  # Then I should see a mismatched password message
  scenario 'visitor cannot sign up with mismatched password and confirmation' do
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver('shortpassword@example.com', 'please123', 'please120')
    expect(page).to have_content 'Please review the problems below:'
    # expect(page).to have_content '1 error prohibited this user from being saved:'
    expect(page).to have_content "Password confirmation doesn't match Password"
    expect(page).to have_content 'Credit card acceptance is pending.'
    expect(page).to have_content 'Password confirmation doesn\'t match'
  end

  # scenario 'visitor cannot sign up with invalid payment information' do
  #  pending 'needs work ? dealt with in spec/stripe ?'
  # end
end
