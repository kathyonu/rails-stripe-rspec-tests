require 'pry'
include Warden::Test::Helpers
Warden.test_mode!

describe 'Account API' do

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

  it 'creates a stripe account', live: true do
    expect(account).to be_a Stripe::Account
    expect(account.id).to match /acct\_/
    expect(account.email).to eq 'bob@example.com'
  end

  it 'retrieves a stripe account', live: true do
    account = Stripe::Account.retrieve()

    expect(account).to be_a Stripe::Account
    expect(account.id).to match /acct\_/
    expect(account.email).to eq 'bob@example.com'
  end

  it 'retrieving a non-existing stripe account raises error', live: true do
    expect { Stripe::Account.retrieve('nope') }.to raise_error { |e|
      expect(e).to be_a Stripe::AuthenticationError
      expect(e.http_status).to eq(401)
    } 
  end

  it 'transfer fails with a could_not_process code', live: true do
    pending 'methods and object names need to be verified'
    expect { Stripe::Account.transfer(card_number: '4000056655665564', amount: 100) }.to raise_error { |e|
      expect(e).to be_a Stripe::TransferError # not sure of this code
      expect(e.http_status).to eq(401)
    } 
  end

  it 'transfer fails when verifying recipient SSN or EIN tax ID', live: true do
    pending 'methods and object names need to be verified'
    expect { Stripe::Account.transfer(account_number: '4000056655665564', amount: 100) }.to raise_error { |e|
      expect(e).to be_a Stripe::TransferError # not sure of this code
      expect(e.http_status).to eq(401)
    } 
  end

  it 'transfer succeeds with an appropriate response', live: true do
    pending 'methods and object names need to be verified'
    expect { Stripe::Account.transfer(card_number: '4000056655665564', amount: 100) }.to raise_error { |e|
      expect(e).to be_a Stripe::TransferError # not sure of this code
      expect(e.http_status).to eq(401)
    } 
  end

  # please choose one of the following two tests by uncommenting it, and commenting out the other
  it 'automatic account transfers are enabled', live: true do
    pending 'test to ensure the Transfer API is set to Automatic transfers enabled option'
  end
    
  # it 'manual account transfers are enabled', live: true do
  #   pending 'test to ensure the Transfer API is set to Manual transfers enabled option'
  # end

  it 'retrieves a stripe account balance', live: true do
    pending 'test the account balance retrieval'
  end

  # set the schedule you wish to make payouts to other accounts : options are ??
  it 'scheduled payouts to other accounts occur on a weekly basis', live: true do
    pending 'test the account payouts schedule'
    # what are the schedule options ? weekly bi-weekly ? monthly 
    # payment = Stripe::Account.transfer() # finish this 
  end

end