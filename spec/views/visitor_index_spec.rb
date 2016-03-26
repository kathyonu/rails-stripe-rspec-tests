# frozen_string_literal: true
include Warden::Test::Helpers
Warden.test_mode!

# New Visitor Sign Up
# As a new visitor to the site
# I want to sign up with my email
# Then gain access to the free Ebook
RSpec.describe Visitor, type: :view, js: true do
  before(:each) do
    @visitor = FactoryGirl.build(:visitor, email: 'visitor@example.com')
  end

  after(:each) do
    Warden.test_reset!
  end

  it 'displays the visitor new page' do
    visit root_path
    expect(current_path).to eq '/' # == /visitors/new
  end

  # also fully passing with real email address
  it '#subscribe' do
    expect(@visitor.persisted?).to eq false
    expect(@visitor.email).to eq('visitor@example.com')

    @visitor.save!
    expect(@visitor.persisted?).to be true
    expect(@visitor.email).to eq('visitor@example.com')
  end
end
