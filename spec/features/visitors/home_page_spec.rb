# frozen_string_literal: true
# Feature: Home page
# As a visitor
# I want to visit a home page
# So I can learn more about the website
feature 'Home page' do
  # Scenario: Visit the home page
  # Given I am a visitor
  # When I visit the home page
  # Then I see the site home page
  scenario 'visitor can view the home page' do
    visit '/home/index' # root_path
    expect(page).to have_content 'My home page text'
  end
end
