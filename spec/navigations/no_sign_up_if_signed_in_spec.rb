# frozen_string_literal: true
# spec/navigation/no_sign_up_if_signed_in_spec.rb
require 'stripe_mock'
include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do |config|
  config.before(:each) do
    StripeMock.start
  end

  config.after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end
end

RSpec.describe 'Navigations', :devise, type: :features, js: true, live: true do
  after(:each) do
    Warden.test_reset!
  end

  describe 'Sign up link is required' do
    describe 'when user is not signed in' do
      it 'any page visitor can see displays the sign up link' do
        # see app/layouts/_navigation.html
        visit '/'
        expect(page).to have_selector('.signup')
      end
    end
  end

  describe 'Sign up link is not required' do
    describe 'when user is signed in' do
      it 'page visits do not show the sign up link' do
        sign_up_silver('Admin Andrew', 'user6@example.com', 'please126', 'please126')

        visit '/content/silver'
        expect(page).not_to have_selector('Sign Up')

        visit '/sequences'
        expect(page).not_to have_selector('Sign Up')

        visit '/sequences/new'
        expect(page).not_to have_selector('Sign Up')
      end
    end
  end
end
