# frozen_string_literal: true
include Warden::Test::Helpers
Warden.test_mode!

# Feature: Navigation links
#   As a visitor
#   I want to see navigation links
#   So I can find home, sign in, or sign up
feature 'Navigation links', js: true do
  before(:each) do
    visit root_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: View navigation links
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see Home, Sign in, and Sign up
  scenario 'view navigation links' do
    expect(page).to have_content 'Sequencers Membership'
    expect(page).to have_content 'Login'
    expect(page).to have_content 'Sign Up'
  end

  scenario 'allows visitor to arrive on the home page' do
    expect(current_path).to eq root_path
  end

  scenario 'allows visitor to view navigation links' do
    expect(page).to have_content 'Welcome'
    expect(page).to have_link 'Database Info'
    expect(page).to have_link 'MailList Info'
    expect(page).to have_link 'Login'
    expect(page).to have_selector('.signup')
    expect(page).to have_link 'Sign Up'
  end

  # version one
  # scenario 'allows visitor to click on the Sign up link' do
  #  visit root_path
  #  click_link 'Sign up'
  #  expect(current_path).to eq '/users/sign_up'
  # end

  # version two
  scenario 'allows visitor to click on the Sign up link' do
    expect(page).to have_selector('.signup')
    expect(page).to have_selector('.nav.navbar.navbar-brand')
    expect(page).to have_selector('ul > .signup')
    within 'ul' do
      find('.signup').click
    end
    expect(current_path).to eq '/home'
    expect(page).to have_content 'Please select a subscription plan below for more information'
  end

  scenario 'allows visitor to type a correct path in the address bar' do
    visit '/users/sign_up?plan=gold'
    expect(current_path).to eq '/users/sign_up'
  end

  # version one
  # scenario 'allows visitor to arrive on sign_up page when typing an incorrect plan in the address bar' do
  #  visit '/users/sign_up?plan=earthling'
  #  expect(current_path).to eq '/users/sign_up'
  # end

  # version two
  scenario 'allows visitor to arrive on home page page when typing an incorrect plan in the address bar' do
    visit '/users/sign_up?plan=earthling'
    expect(current_path).to eq '/home'
  end
end
