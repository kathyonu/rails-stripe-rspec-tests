# frozen_string_literal: true
include Warden::Test::Helpers
Warden.test_mode!

# Feature: Product acquisition
#   As a user
#   I want to download the product
#   So I can complete my acquisition
feature 'Product acquisition', js: true do
  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Download the product
  #   Given I am a user
  #   When I click the 'Download' button
  #   Then I should receive a PDF file
  scenario 'Download the product after signing up as normal user' do
    user = FactoryGirl.create(:user)
    login_as(user, scope: :user)
    visit root_path
    expect(page).to have_content 'Download a free book'
    click_link_or_button 'Download PDF'
    expect(page.response_headers['Content-Type']).to have_content 'application/pdf'
  end

  # Scenario: Download the product
  #   Given I am a user
  #   When I click the 'Download' button
  #   Then I should receive a PDF file
  scenario 'Download the product after visitor sign up with only email' do
    visit root_path
    expect(current_path).to eq '/'
    expect(page).to have_content 'Please accept our ebook'

    fill_in 'Email', with: 'visitor@example.com'
    click_link_or_button('Download free ebook')
    expect(current_path).to match(/visitors/)
    expect(page).to have_content 'the free ebook title'
  end
end
