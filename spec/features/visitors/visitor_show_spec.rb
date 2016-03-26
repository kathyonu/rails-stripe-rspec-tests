# frozen_string_literal: true
include Warden::Test::Helpers
Warden.test_mode!

# Feature: Home Page
# As a registered visitor to the site
# I want to enter my email
# To regain access to the free Ebook
feature Visitor, js: true do
  before(:each) do
    @visitor = FactoryGirl.create(:visitor, email: 'visitor@example.com')
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Visit the home page
  # Given I am a visitor
  # When I visit the /visitors/new page
  # Then I see "Good Works On Earth .."
  scenario 'visitor can revisit the /visitors page' do
    visit root_path
    expect(current_path).to eq '/' # => /visitors/new
    expect(page).to have_content 'Welcome'
    expect(@visitor.persisted?).to be true
    expect(@visitor.email).to eq('visitor@example.com')

    visit '/visitors/new'
    expect(current_path).to eq '/visitors/new'

    fill_in 'Email', with: 'signup@example.com'
    click_button 'Take a Trip Across the Letters Trestle'
    expect(current_path).to match(/visitors/)
  end
end
