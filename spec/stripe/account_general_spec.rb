# these tests are NOT yet ready for prime time
# these tests have NOT yet been run against a working app with accounts in place to be tested
# this file may still contain duplicates among the account tests, refactoring those out will occur
require 'pry'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Account API', live: true do

  before(:each) do
    StripeMock.start
    account = Stripe::Account.create(
      managed: false,
      country: 'US',
      email: 'bob@example.com'
    )
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it 'creates a stripe account' do
    pending 'not creating account, and first expectation is probably not correct'
    expect(account).to be_a Stripe::Account
    expect(account.id).to match /acct\_/
    expect(account.email).to eq 'bob@example.com'
  end

  it 'retrieves a stripe account' do
    account = Stripe::Account.retrieve()
    expect(account).to be_a Stripe::Account
    expect(account.id).to match /acct\_/
    expect(account.email).to eq 'bob@example.com'
  end

  it 'retrieving a non-existing stripe account raises error' do
    expect { Stripe::Account.retrieve('nope') }.to raise_error { |e|
      expect(e).to be_a Stripe::AuthenticationError
      expect(e.http_status).to eq(401)
    }
  end

  it 'retrieves a stripe account balance' do
    pending 'test the account balance retrieval'
    account = Stripe::Account.retrieve()
    balance = Stripe::Balance.retrieve()
    expect(account.balance).to eq balance
  end

  it 'transfers money from our account to user account' do
    pending 'test transferring money to user account'
    account = Stripe::Account.retrieve()
    balance = Stripe::Balance.retrieve()
    transfer = Stripe::Account.transfer(card_number: '4000056655665564', amount: 100)
    expect(response).to be true
    expect(balance).to eq balance - transfer.amount
  end

  # Authentication via the Stripe-Account header
  it 'creates and retrieves a connected stripe account' do
    pending 'needs more work'
    Stripe.api_key = PLATFORM_SECRET_KEY
    Stripe::Customer.create(
      { description: "example@stripe.com" },
      { stripe_account: CONNECTED_STRIPE_ACCOUNT_ID }
    )
    # Fetching an account just needs the ID as a parameter
    Stripe::Account.retrieve(CONNECTED_STRIPE_ACCOUNT_ID)
  end

  it 'allows admin to change bank account details' do
    pending 'actual case scenario, an address change, still incomplete'
    account = Stripe::Account.retrieve()
    account.address.line1 = "Your Street, Your Suite"
    account.address.line2 = nil
    account.address.city = "Your City"
    account.address.state = "OR"
    account.address.postal_code = "12345"
    account.address.country = "US"
    expect(ations).to be 'written'
  end
end