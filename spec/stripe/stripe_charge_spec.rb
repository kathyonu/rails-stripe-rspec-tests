require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Charge API', live: true do
    
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it "tests idempotency_key" do
    pending 'tests the operation of the idempotency_key'
    charge = Stripe::Charge.create({
      amount: 900,
      currency: 'usd',
      source: stripe_helper.generate_card_token(card_number: 4242424242424242, exp_month: 8, exp_year: 2018),
      description: "Charge for user@example.com",
      }, {
        idempotency_key: "95ea4310438306ch"
    })
#binding.pry
    expect(charge.idempotency_key).to eq "95ea4310438306ch"
   #expect(ations).to be 'written' ??
  end

  it "creates a stripe charge item with a card token" do
    charge = Stripe::Charge.create({
      amount: 900,
      currency: 'usd',
      source: stripe_helper.generate_card_token(card_number: 4242424242424242, exp_month: 9, exp_year: 2019),
      description: "Charge for user@example.com",
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    expect(charge.id).to match /^test\_ch/
    expect(charge.amount).to eq 900
    expect(charge.description).to eq "Charge for user@example.com"
    expect(charge.captured).to eq true
  end

  it "creates a stripe charge item with a customer and card id" do
    card_token = stripe_helper.generate_card_token(card_number: 4242424242424242, exp_month: 10, exp_year: 2020)
    customer = Stripe::Customer.create({
      email: 'chargeitem@example.com',
      source: card_token,
      description: "customer creation with card token",
    })
   charge = Stripe::Charge.create({
      amount: 900,
      currency: 'usd',
      customer: customer.id,
      description: 'a charge with a specific card',
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    card_token = customer.sources.data[0].id
    charge = Stripe::Charge.retrieve(charge.id)
    customer = Stripe::Customer.retrieve(customer.id)
    expect(card_token).to match /^test_cc/
    expect(charge.id).to match /^test_ch/
    expect(customer.id).to match /^test_cus/
    expect(customer.sources.data[0].id).to match /^test_cc/
    expect(customer.sources.data.length).to eq 1
    expect(customer.sources.data[0].id).not_to be_nil
    expect(customer.sources.data[0].last4).to eq '4242'
  end

  it "creates a stripe charge with a specific customer card" do
    begin
      card_token = stripe_helper.generate_card_token(card_number: '5555555555554444', exp_month: 11, exp_year: 2021)
      customer = Stripe::Customer.create({
        email: 'chargeitem@example.com',
        source: card_token,
        description: "customer creation with card token",
      })
      expect(customer.id).to match /^test_cus/
      charge = Stripe::Charge.create({
        amount: 900,
        currency: 'usd',
        customer: customer.id,
        source: card_token,
        description: 'a charge with a specific card',
        }, {
          idempotency_key: "95ea4310438306ch"
      })
    rescue Stripe::CardError => e
      body = e.json_body
      err = body[:error]
      puts "Status is: #{e.http_status}"
      puts "Type is: #{err[:type]}"
      puts "Code is: #{err[:code]}"
      # param is '' in this case
      puts "Param is: #{err[:param]}"
      puts "Message is: #{err[:message]}"
    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
    rescue Stripe::StripeError => e
      # Display a very generic error to the user, and maybe send
      # yourself an email
    rescue => e # Something else happened, completely unrelated to Stripe
      expect(charge.amount).to eq 900
      expect(charge.description).to eq 'a charge with a specific card'
      expect(charge.captured).to eq true
      expect(charge.card.last4).to eq '4242' 
      expect(charge.id).to match /^test_ch/
    end
  end

  it "requires a valid card token" do
    expect {
      charge = Stripe::Charge.create({
        amount: 900,
        currency: 'usd',
        source: 'bogus_card_token',
        description: "Charge for user@example.com",
      }, {
        "idempotency_key": "95ea4310438306ch"
      })
    }.to raise_error(Stripe::InvalidRequestError, /Invalid token id/)
  end

  it "requires presence of amount" do
    expect {
      charge = Stripe::Charge.create({
        currency: 'usd',
        source: stripe_helper.generate_card_token,
        }, {
          "idempotency_key": "95ea4310438306ch"
      })
    }.to raise_error(Stripe::InvalidRequestError, /missing required param: amount/i)
  end

  it "requires presence of currency" do
    expect { Stripe::Charge.create({
        amount: 99,
        source: stripe_helper.generate_card_token,
      }, {
        "idempotency_key": "95ea4310438306ch"
      })
    }.to raise_error(Stripe::InvalidRequestError, /missing required param: currency/i)
  end

  it "requires a valid positive amount" do
    expect {
      charge = Stripe::Charge.create({
        amount: -99,
        currency: 'usd',
        source: stripe_helper.generate_card_token
      }, {
        "idempotency_key": "95ea4310438306ch"
      })
    }.to raise_error(Stripe::InvalidRequestError, /invalid positive integer/i)
  end

  it "requires a valid integer amount" do
    expect {Stripe::Charge.create({
      amount: 99.0,
      currency: 'usd',
      source: stripe_helper.generate_card_token,
      }, {
        "idempotency_key": "95ea4310438306ch"
      })
    }.to raise_error(Stripe::InvalidRequestError, /invalid integer/i)
  end

  it "creates a stripe charge item with a card token" do
    charge = Stripe::Charge.create({
      amount: 900,
      currency: 'usd',
      source: stripe_helper.generate_card_token,
      description: 'card charge',
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    expect(charge.id).to match /^test_ch/
    expect(charge.amount).to eq 900
    expect(charge.description).to eq 'card charge'
    expect(charge.captured).to eq true
    expect(charge.paid).to eq true
    expect(charge.status).to eq 'succeeded'
  end

  it "creates a stripe charge item with a customer and card id" do
    customer = Stripe::Customer.create({
      email: 'johnny@appleseed.com',
      source: stripe_helper.generate_card_token(number: '4012888888881881'),
      description: "a description"
    })
    expect(customer.sources.data.length).to eq 1
    expect(customer.sources.data[0].id).not_to be_nil
    expect(customer.sources.data[0].last4).to eq '1881' 
    card = customer.sources.data[0]
    charge = Stripe::Charge.create({
      amount: 900,
      currency: 'usd',
      customer: customer.id,
      source: card.id,
      description: 'a charge with a specific card',
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    expect(charge.id).to match /^test_ch/
    expect(charge.amount).to eq 900
    expect(charge.description).to eq 'a charge with a specific card'
    expect(charge.captured).to eq true
    expect(charge.source.last4).to eq '1881'
  end

  it "retrieves a stripe charge" do
    original = Stripe::Charge.create({
      amount: 900,
      currency: 'usd',
      source: stripe_helper.generate_card_token,
      description: 'Charge for user@example.com',
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    charge = Stripe::Charge.retrieve(original.id)
    expect(charge.id).to eq original.id
    expect(charge.amount).to eq original.amount
  end

  it "cannot retrieve a charge that doesn't exist" do
    begin
      expect(Stripe::Charge.retrieve('nope')).to raise_error { |e|
      expect(e).to be_a Stripe::InvalidRequestError, "No such charge: nope"
      expect(e.param).to eq 'charge'
      expect(e.http_status).to eq 404
      }
    rescue Stripe::CardError => e
      # Since it's a decline, Stripe::CardError will be caught
      body = e.json_body
      err  = body[:error]
      puts "Status is: #{e.http_status}"
      puts "Type is: #{err[:type]}"
      puts "Code is: #{err[:code]}"
      # param is '' in this case
      puts "Param is: #{err[:param]}"
      puts "Message is: #{err[:message]}"
    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
    rescue Stripe::StripeError => e
      # Display a very generic error to the user, and maybe send
      # yourself an email
    rescue => e
      # Something else happened, completely unrelated to Stripe
    end
  end
end