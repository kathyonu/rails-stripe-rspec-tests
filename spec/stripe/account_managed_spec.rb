# these tests are NOT quite ready for prime time
# these tests have NOT yet been run against a working app with accounts in place to be tested
# this file may still contain duplicates among the account tests, refactoring those out will occur
=begin
require 'pry'

include Warden::Test::Helpers
Warden.test_mode!

# managed accounts only
describe 'Account API', type: :controller, live: true do

  before(:each) do
    StripeMock.start
    account = Stripe::Account.create(
      managed: true,
      country: 'US',
      email: 'bob@example.com'
    )
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  # Managed Accounts : https://stripe.com/docs/connect/managed-accounts
  # to see country codes available : https://stripe.com/global
  it 'allows managed account to be created with just the country code' do
    pending 'not creating account, and response expectation is not correct'
    managed_account = Stripe::Account.create(
      managed: true,
      country: 'US'
    )
    # binding.pry # this call will open your console in Pry, in the test environment
    # this call can be moved anywhere inside an `it do` block
    # once you have the test passing, remove the binding.pry call
    expect(response).to be_a Stripe::Account
    expect(account.id).to match(/^acct\_/)
    expect(account.managed).to be true
  end

  # Managed Accounts : Authentication via API keys
  # Reference        : https://stripe.com/docs/connect/authentication
  it 'authenticates managed account using API keys' do
    pending 'not creating account, and response expectation is probably not correct'
    Stripe.api_key = ENV['STRIPE_API_KEY']
    Stripe::Account.create({
      managed: true,
      country: 'US'
    })
    expect(response).to be_a Stripe::Account
    expect(account.id).to match(/^acct\_/)
    expect(account.keys.secret).to match(/^sk_live\_/)
    expect(account.keys.publishable).to match(/^pk_live\_/)
    expect(account.managed).to be true
  end

  it 'stores information about the managed account' do
    pending 'needs a lot more work to be done after account is migrated into working app'
    connected_stripe_account_id = ("code to store it")
    platform_secret_key = ("code to store it")
    account = Stripe::Account.retrieve()
    expect(connected_stripe_account_id).to eq account.id
    expect(platform_secret_key).to eq Stripe::Account.retrieve(code_to_retrieve)
  end

  it 'allows us to change users bank account info' do
    pending 'write code to change user bank account number'
  end

  it 'transfer fails with a could_not_process code' do
    pending 'methods and object names need to be verified'
    expect { Stripe::Account.transfer(card_number: '4000056655665564', amount: 100) }.to raise_error { |e|
      expect(e).to be_a Stripe::TransferError # not sure of this code
      expect(e.http_status).to eq(401)
    }
  end

  it 'transfer fails when verifying account owners SSN or EIN tax ID' do
    pending 'methods and object names need to be verified'
    expect { Stripe::Account.transfer(account_number: '4000056655665564', amount: 100) }.to raise_error { |e|
      expect(e).to be_a Stripe::TransferError # not sure of this code
      expect(e.http_status).to eq(401)
    }
  end

  it 'transfer succeeds with an appropriate response' do
    pending 'methods and object names need to be verified'
    expect { Stripe::Account.transfer(card_number: '4000056655665556', amount: 100) }.to raise_error { |e|
      expect(e).to be_a Stripe::TransferError # not sure of this code
      expect(e.http_status).to eq(401)
    }
  end

  it 'retrieves all bank accounts attached to this account' do
    pending 'this should now pass'
    account = Stripe::Account.retrieve()
    account.external_accounts { include[]=total_count } # this line is probably no longer required, #TODO: test it
    expect(account.external_accounts.total_count).to eq 1
    expect(account.external_accounts.data.first.id).to match /^ba\_/
    # Ref for new above from old below: 20151015
    # https://stripe.com/docs/upgrades?since=2015-09-08#api-changelog
    # "bank_accounts is no longer a field in the Account object.
    # Use external_accounts instead. Also, bank_account"
    # will be replaced by external_account in fields_needed.
    # account.bank_accounts { include[]=total_count }
    # expect(account.bank_accounts.total_count).to eq 1
    # expect(account.bank_accounts.data.first.id).to match /^ba\_/  end

  it 'shows if stripe will attempt to reclaim negative balances from this account' do
    account = Stripe::Account.retrieve()
    negative_balances_claimed = account.debit_negative_balances
    expect(negative_balances_claimed).to eq true
  end

  ### the avs (zip/postal code) and cvc (3 digit card verification code) settings are set in your Stripe Dashboard
  ### these are account-level settings to automatically decline certain types of charges regardless of the bank’s decision
  it 'verifies your decline_charge_on avs and cvc settings' do
    account = Stripe::Account.retrieve()
    decline_charge = account.decline_charge_on
    expect(decline_charge.avs_failure).to be false
    expect(decline_charge.cvc_failure).to be true
  end

  ### verifies account owner information is set at stripe
  it 'verifies the owner and verification status of this account' do
    account = Stripe::Account.retrieve()
    account_owner = account.legal_entity
    account_verification = account.verification
    expect(account_owner).to eq "Your Account Name"
    expect(account_verification.status).to eq "verified"  # possible values are unverified, pending, verified
    expect(account_verification.document).to eq nil
    expect(account_verification.details).to eq nil
  end

  ### verified an internal-only description of the product or service provided
  it 'verified product_description exists' do
    account = Stripe::Account.retrieve()
    description = account.product_description
    expect(description).to eq "Your product or service description as set in your Dashboard"
  end

  it 'verifies the stripe terms of service have been accepted' do
    account = Stripe::Account.retrieve()
    acceptance_details = account.tos_acceptance
    expect(acceptance_details.date).to_not be nil            # to verify you have an account, and terms have been accepted
    expect(acceptance_details.ip).to match(/your_ip_address/)  # ip address you used to accept stripe's terms of service
    expect(acceptance_details.user_agent).to match(/Firefox/)  # browser you used to sign up with stripe
  end

  ### if you have montlhy payouts, use this test and comment out the next two
  it 'verifies monthly transfer schedule settings' do
    account = Stripe::Account.retrieve()
    days_delay = account.delay_days
    payout_interval = account.interval       # choices are daily, weekly, monthly, and; manual, on transfers created only via API call
    anchor_date = account.monthly_anchor     # day of month funds are paid out if interval is set to monthly
    expect(days_delay).to eq 2
    expect(payout_interval).to eq 'monthly'
    expect(anchor_date).to eq 5              # any day of the month, as set in your dashboard
  end

  ### if you have weekly payouts, use this test and comment out the one above and the one below
  it 'verifies weekly transfer schedule settings' do
    account = Stripe::Account.retrieve()
    days_delay = account.transfer_sechedule.delay_days
    payout_interval = account.interval
    anchor_date = account.weekly_anchor      # day of week funds are paid out if interval is set to weekly
    expect(days_delay).to eq 2
    expect(payout_interval).to eq 'weekly'
    expect(anchor_date).to eq 'tuesday'      # any day of the week, as set in your Dashboard
  end

  ### if you have daily payouts, use this test and comment out the above two
  it 'verifies daily transfer schedule settings' do
    account = Stripe::Account.retrieve()
    days_delay = account.transfer_sechedule.delay_days
    payout_interval = account.interval
    expect(days_delay).to eq 2
    expect(payout_interval).to eq 'daily'
  end

  ### Identity Verification for Managed Accounts
  ### https://stripe.com/docs/connect/identity-verification
  it 'tests if verification of a connected account is required' do
    account = Stripe::Account.retrieve()
    account_owner = account.legal_entity
    account_verification = account.verification
    expect(account_owner).to eq "Your Account Name"
    if expect(account_verification.status).to eq "pending" || "unverified"
      expect(account_verification.document.id).to match(/^file\_/)
      expect(account_verification.details).to eq nil
    end
    if expect(account_verification.status).to eq "failed"
      expect(account_verification.document.id).to_not match(/^file\_/)    # code smell
      expect(account_verification.details).to_not match("^[a-zA-Z0-9]+$") # code smell
    end
  end

  # verifies bank account routing numbers
  # https://stripe.com/docs/testing
  it 'verifies account user bank account routing number' do
    pending 'hmm, how do i write this one'
    account = Stripe::Account.retrieve(account_number: '110000000')
    bank_routing_number = account.routing_number
    expect(response).to be "STRIPE TEST BANK US routing number"
    transfer = Stripe::Account.transfer(account_number: '110000000', amount: 100)
    expect(response).to be "what?"
  end

  # verifies successful bank account numbers can transfer funds
  # https://stripe.com/docs/testing
  it 'verifies our platform can interact with account user bank account' do
    account = Stripe::Account.retrieve(account_number: '000123456789')
    expect(response).to match(/^succeeded/)  # not sure of this yet
    transfer = Stripe::Account.transfer(account_number: '000123456789', amount: 100)
    expect(response).to match(/^succeeded/)
  end

  # verifies unsuccessful bank account numbers cannot transfer funds
  # https://stripe.com/docs/testing
  it 'verifies our platform can interact with account user bank account' do
    account = Stripe::Account.retrieve(account_number: '000111111116')
    expect(response).to match(/^no_account/)
    transfer = Stripe::Account.transfer(account_number: '000111111116', amount: 100)
    expect(response).to match(/^no_account/)
  end

  # verifies unsuccessful bank account numbers cannot transfer funds
  # https://stripe.com/docs/testing
  it 'verifies non-existent account user bank account fails' do
    account = Stripe::Account.retrieve(account_number: '000111111113')
    expect(response).to 'match(/^account_closed/)
    transfer = Stripe::Account.transfer(account_number: '000111111113', amount: 100)
    expect(response).to 'match(/^account_closed/)
  end

  # verifies unsuccessful debit card numbers cannot receive funds
  # https://stripe.com/docs/testing
  it 'verifies non-existent account user debit card account fails' do
    account = Stripe::Account.retrieve(account_number: 'get-right-number-for-testing-debit-card')
    expect(response).to 'match(/^no_account/)
    transfer = Stripe::Account.transfer(account_number: 'get-right-number-for-testing', amount: 100)
    expect(response).to 'match(/^no_account/)
  end

  ### standalone managed or both ? on the next two tests
  # please choose one of the following two tests by uncommenting it, and commenting out the other
  # NOTE : You may not reverse automatic Stripe transfers : https://stripe.com/docs/api#transfer_reversals 
  it 'automatic account transfers are enabled' do
    pending 'test to ensure the Transfer API is set to Automatic transfers enabled option'
  end

  # it 'manual account transfers are enabled' do
  #   pending 'test to ensure the Transfer API is set to Manual transfers enabled option'
  # end

  # standalone or managed or both ?
  # https://stripe.com/docs/testing
  # 4000056655665556 is a Visa debit transfer test number that will succeed.
  it 'transfers money from our account to user account' do
    pending 'test transferring money to user account'
    account = Stripe::Account.retrieve()
    balance = Stripe::Balance.retrieve()
    transfer = Stripe::Account.transfer(card_number: '4000056655665556', amount: 100)
    expect(response).to be true
    expect(balance).to eq balance - transfer.amount
  end

  ### Transfer failures that can be tested 
  ### The reason a given transfer failed is available in the failure_code attribute of a Transfer object
  ### This is a list of all the types of failure codes Stripe currently send : as of 20150611
  ### Stripe may add more at any time, so you shouldn't rely on only these failure codes existing in your code.
  it 'insufficient_funds' do
    pending 'write the code'
  end

  it 'account_closed' do
    pending 'write the code'
  end

  it 'no_account' do
    pending 'write the code'
  end

  it 'invalid_account_number' do
    pending 'write the code'
  end

  it 'debit_not_authorized' do
    pending 'write the code'
  end

  it 'bank_ownership_changed' do
    pending 'write the code'
  end

  it 'account_frozen' do
    pending 'write the code'
  end

  # 4000056655665564 is a Visa debit transfer test number that will fail with a could_not_process code
  it 'could_not_process' do
    pending 'now written, see could_not_process line 71'
  end

  it 'bank_account_restricted' do
  # should above now be written as below ? : https://stripe.com/docs/upgrades?since=2015-09-08#api-changelog
  # answer is NO as it is still valid and used only in transfers : https://stripe.com/docs/api#transfer_failures
  # it 'external_account_restricted' do
    pending 'write the code'
  end

  it 'invalid_currency' do
    pending 'write the code'
  end

  ### Transfers reversals can be tested
  ### https://stripe.com/docs/api#create_transfer_reversal
  it 'it processes and verifies Stripe::Transfer.reversal' do
    pending 'first four lines of code are from Stripe'
    # tr = Stripe::Transfer.retrieve({TRANSFER_ID})
    # reversal = tr.reversals.create
    #
    # tr = Stripe::Transfer.retrieve("tr_YourAlphaNumericString")
    # reversal = tr.reversals.create
    # 
    # Note on the above TRANSFER_ID :
    # To retrieve a transfer_id, we need to have created one, a transfer that is, so it has an ID.
    # expect(response).to 'match(/^trr\_/)
    # expect(tr.id).to 'match(/^tr\_/)
    # transfer_reversal = Stripe::TransferReversal.retrieve(reversal.id)
    # expect(ations).to be 'needs more work'
  end

  ### Managed Account only
  it 'allows admin to change bank account details' do
    pending 'actual case scenario, an address change'
    account = Stripe::Account.retrieve()
    account.address.line1 = "Your Street, Your Suite"
    account.address.line2 = nil
    account.address.city = "Your City"
    account.address.state = "OR"
    account.address.postal_code = "12345"
    account.address.country = "US"
    expect(ations).to be 'written'
  end

  # standalone, managed, or both ?
  # verifies the name of the `recipient`* user is required by law
  # *'recipient' is no longer used : replaced by `account`
  it 'verifies the full legal name of the managed account user' do
    pending 'have not finished : in Standalone Stripe may do this'
    user = User.find_by_email('managed_account_user@example.com')
    account = Stripe::Account.retrieve(user.account_id)
    expect(ations).to be 'written'
  end
end
=end
