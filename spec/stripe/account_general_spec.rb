# these tests are NOT quite ready for prime time
# these tests have NOT yet been run against a working app with accounts in place to be tested
# this file may still contain duplicates among the account tests, refactoring those out will occur
require 'pry'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Account API', live: true do

  before(:each) do
    StripeMock.start
    account = Stripe::Account.create(
      { managed: false,
        country: 'US',
        email: 'bob@example.com',
      }
    )
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it 'creates a stripe account' do
    pending 'need create account first'
    expect(account).to be_a Stripe::Account
    expect(account.id).to match /acct\_/
    expect(account.email).to eq 'bob@example.com'
  end

  it 'retrieves a stripe account' do
    pending 'need to create account first'
    account = Stripe::Account.retrieve()
    expect(account).to be_a Stripe::Account
    expect(account.id).to match /acct\_/
    expect(account.email).to eq 'bob@example.com'
  end

  it 'retrieving a non-existing stripe account raises error' do
    pending 'need to create account first'
    expect { Stripe::Account.retrieve('nope') }.to raise_error { |e|
      expect(e).to be_a Stripe::AuthenticationError
      expect(e.http_status).to eq(401)
    }
  end

  it 'retrieves a stripe account balance' do
    pending 'need to create acccount first, then test the account balance retrieval'
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

  # Verify this is a general account spec, common to both Standalone and Managed
  # Authentication via the Stripe-Account header
  it 'creates and retrieves a connected stripe account' do
    pending 'needs more work re CONNECTED_STRIPE_ACCOUNT_ID'
    Stripe.api_key = ENV(['STRIPE_API_KEY'])
    Stripe::Customer.create(
      { email: "example@stripe.com" },
      { stripe_account: CONNECTED_STRIPE_ACCOUNT_ID },
    )
    # Fetching an account just needs the ID as a parameter
    Stripe::Account.retrieve(CONNECTED_STRIPE_ACCOUNT_ID)
  end

  # Verify this is a general account spec, allowing account owner to change account address
  it 'allows admin to change bank account details' do
    pending 'actual case scenario, an address change'
    # create the account here, first : then change it using below code, then write expectations
    account = Stripe::Account.retrieve()
    account.address.line1 = "Your Street, Your Suite"
    account.address.line2 = nil
    account.address.city = "Your City"
    account.address.state = "OR"
    account.address.postal_code = "97000" 
    account.address.country = "US" 
  end

  # general, standalone or managed ?
  # verifies the name of the `recipient`* user as required by law
  # *'recipient' is no longer used : replaced by `account`
  it 'verifies the full legal name of the managed account user' do
    pending 'have not finished : in Standalone Stripe may do this'
    user = User.find_by_email('managed_account_user@example.com')
    account = Stripe::Account.retrieve(user.account_id)
    expect(ations).to be 'written'
  end
end