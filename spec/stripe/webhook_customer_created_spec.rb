require 'pry'
require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Stripe Customer Webhooks' do

  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it "mocks a stripe webhook" do
    # a customer.created event will have the same information as retrieving the relevant customer would
    # https://stripe.com/docs/api#retrieve_event
    event = StripeMock.mock_webhook_event('customer.created')

    customer_event_data_object = event.data.object
    expect(customer_event_data_object.id).to_not be_nil

    customer = Stripe::Customer.create(email: 'customer@example.com')
    customer_id = customer.id
    customer.subscriptions { include[]=total_count }
    user = Stripe::Customer.retrieve(customer_id)
    expect(user.sources.object).to eq 'list'
    expect(user.default_source).to eq nil
    expect(user.sources.url).to match /^\/v1\/customers\/test_cus\_.+\/sources/
    event.data.object { include[]=sources }
    expect(event.data.object.cards { include=total_count }).to be_truthy
    expect(event.data.object.default_card).to match /^cc\_/    # ? out of date stripe_mock
   #expect(event.data.object.default_source).to match /^cc\_/  # fails
    event.data { include[]=cards }                             # ? out of date stripe_mock
    expect(event.data { include=object }).to be_truthy
    expect(event.data.object { include=cards }).to be_truthy
    expect(event.id).to match /^test_evt/
    expect(event.data.object.id).to match /^cus\_/
    expect(event.data.object[:id]).to match /^cus\_/
    expect(event.data.object.object).to eq 'customer'
    expect(event.data.object.livemode).to be false
    expect(event.data.object.description).to be nil
    expect(event.data.object.email).to eq 'bond@mailinator.com'
    expect(event.data.object.delinquent).to be true
    event.data.object.cards { include=data }
    expect(event.data.object.cards { include=data }).to be_truthy
    expect(event.data.object.cards.count).to eq 1
    expect(event.data.object.cards.data.first[:id]).to match /^cc\_/
    expect(event.data.object.cards.data.first[:customer]).to match /^cus\_/
    expect(event.data.object.cards.data.first[:last4]).to eq '0341'
    expect(event.data.object.cards.data.first[:type]).to eq 'Visa'
    expect(event.data.object.cards.data.first[:funding]).to eq 'credit'
    expect(event.data.object.cards.data.first.exp_month).to eq 12
    expect(event.data.object.cards.data.first.exp_year).to eq 2013
    expect(event.data.object.cards.data.first.fingerprint).to_not be nil
    expect(event.data.object.cards.data.first.customer).to match /^cus\_/
    expect(event.data.object.cards.data.first.country).to eq 'US'
    expect(event.data.object.cards.data.first.name).to eq 'Johnny Goodman'
    expect(event.data.object.cards.data.first.address_line1).to be nil
    expect(event.data.object.cards.data.first.address_line2).to be nil
    expect(event.data.object.cards.data.first.address_city).to be nil
    expect(event.data.object.cards.data.first.address_state).to be nil
    expect(event.data.object.cards.data.first.address_zip).to be nil
    expect(event.data.object.cards.data.first.address_country).to be nil
    expect(event.data.object.cards.data.first.cvc_check).to eq 'pass'
    expect(event.data.object.cards.data.first.address_line1_check).to be nil
    expect(event.data.object.cards.data.first.address_zip_check).to be nil
   #customer.subscriptions { include[]=total_count }
#fails expect(event.data.object.cards.id).to match /^cc\_/
#fails expect(event.sources.data.id).to match /^cc\_/
#fails expect(event.data.object.cards.default_card).to match /^cc\_/
#fails expect(event.data.object.sources.default_card).to match /^cc\_/
#fails expect(event.data.object.sources.default_source).to match /^cc\_/
#fails expect(customer.object.default_card).to match /^cc\_/

#fails expect(event.data.object.cards.data[:object]).to eq 'card'
#fails expect(event.data.object.cards.data).to eq 'card'
#fails expect(event.data.object.cards.data).to match /^cc\_/
#    expect(event.data.object.cards.data[1]).to match /^cc\_/ # => nil
    expect(event.data.object.object).to eq 'customer'
    expect(event.data.object.livemode).to be false
    expect(event.data.object.description).to be nil
   #expect(event.data.object.email).to eq 'event_webhook@example.com'
    expect(event.data.object.email).to eq 'bond@mailinator.com'   # ? out of date stripe_mock
    expect(event.data.object.delinquent).to be true
   #expect(event.data.object.metadata).to match /^Stripe::StripeObject/
    expect(event.data.object.subscription).to be nil
    expect(event.data.object.discount).to be nil
    expect(event.data.object.discount).to be nil
    expect(event.data.object.account_balance).to eq 0 
    expect(event.data.object.cards.object).to eq 'list' 
    expect(event.id).to match /^test_evt\_/
    expect(event.created).to_not be nil
    expect(event.livemode).to eq false
    expect(event.type).to eq 'customer.created'
    expect(event.object).to eq 'event'
    expect(event.data.object.account_balance).to eq 0
    expect(event.data.object.cards.object).to eq 'list'
    expect(event.data.count).to eq 1
    expect(event.url).to match /\/v1\/events\/test_evt_/
    expect(event.data.object.cards).to_not be_nil
    expect(event.data.object.cards.data.first[:id]).to match /^cc\_/
    expect(event.data.object.cards.data.first[:last4]).to eq '0341'
    expect(event.data.object.cards.data.first[:type]).to eq 'Visa'
    expect(event.data.object.cards.data.first[:brand]).to eq 'Visa'
    expect(event.data.object.cards.data.first[:funding]).to eq 'credit'
    expect(event.data.object.cards.data.first[:exp_month]).to eq 12
    expect(event.data.object.cards.data.first[:exp_year]).to eq 2013  # out of date stripe_mock
   #expect(event.data.object.cards.data.first[:exp_year]).to eq 2019
    expect(event.data.object.cards.data.first[:fingerprint]).to_not be nil
    expect(event.data.object.cards.data.first[:customer]).to match /^cus\_/
    expect(event.data.object.cards.data.first[:country]).to eq 'US'
    expect(event.data.object.cards.data.first[:name]).to eq 'Johnny Goodman'
    expect(event.data.object.cards.data.first[:address_line1]).to eq nil
    expect(event.data.object.cards.data.first[:address_line2]).to eq nil
    expect(event.data.object.cards.data.first[:address_city]).to eq nil
    expect(event.data.object.cards.data.first[:address_state]).to eq nil
    expect(event.data.object.cards.data.first[:address_zip]).to eq nil
    expect(event.data.object.cards.data.first[:address_country]).to eq nil
    expect(event.data.object.cards.data.first[:cvc_check]).to eq 'pass'
    expect(event.data.object.cards.data.first[:address_line1_check]).to eq nil
    expect(event.data.object.cards.data.first[:address_zip_check]).to eq nil
    customer_object = event.data.object
    expect(customer_object.id).to_not be_nil
    expect(customer_object.default_card).to_not be_nil        # ? out of date stripe_mock
   #expect(customer_object.default_source).to_not be_nil
    expect(customer_object.default_card).to match /^cc\_/   # ? out of date stripe_mock
   #expect(customer_object.default_source).to match /^cc\_/
  end
end