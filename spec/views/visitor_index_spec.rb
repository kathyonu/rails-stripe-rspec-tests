include Warden::Test::Helpers
Warden.test_mode!

# New Visitor Sign Up
# As a new visitor to the site
# I want to sign up with my email
# Then gain access to the free Ebook
RSpec.describe Visitor do

  before(:each) do
    @visitor = FactoryGirl.create(:visitor)
  end

  after(:each) do
    Warden.test_reset!
  end

  it '#subscribe' do
    expect(@visitor.subscribe).to eq true
    expect(@visitor.email).to eq("visitor@example.com")
  end
end