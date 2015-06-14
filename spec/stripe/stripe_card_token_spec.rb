require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Stripe token' do

  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  describe 'Direct Token Creation' do
    it 'generates and reads a card token for create charge' do
      card_token = StripeMock.generate_card_token(number: '4242424242424242', exp_month: 7, exp_year: 2017)
      charge = Stripe::Charge.create({
        amount: 900,
        currency: "usd",
        source: card_token,
        description: "Charge for user@example.com",
        }, {
          idempotency_key: "95ea4310438306ch"
      })
      card = charge.source
      expect(card.id).to match(/^test_cc/)
      expect(card.last4).to eq '4242'
      expect(card.exp_month).to eq 7
      expect(card.exp_year).to eq 2017
    end

    it 'generates and reads a card token for create customer' do
      card_token = StripeMock.generate_card_token(card_number: '4242424242424242', exp_month: 8, exp_year: 2018)
      customer = Stripe::Customer.create({ source: card_token }, { idempotency_key: "95ea4310438306ch" })
      expect(card_token).to match /^test_tok/
      expect(customer.id).to match /^test_cus/
      expect(customer.sources.first.last4).to eq '4242'
      expect(customer.sources.first.exp_month).to eq 8
      expect(customer.sources.first.exp_year).to eq 2018
    end

    it 'generates and reads a card token for update customer' do
      card_token = StripeMock.generate_card_token(number: '4242424242424242', exp_month: 9, exp_year: 2019)
      customer = Stripe::Customer.create({ source: card_token })
      customer.card = card_token
      customer.save
      card = customer.sources.data.first
      expect(card_token).to match /^test_tok/
      expect(customer.sources.data.first.id).to match /^test_cc/
      expect(customer.id).to match /^test_cus/
     #expect(customer.subscriptions).to be nil
     #expect(customer.subscriptions.data).to be nil
      customer.subscriptions { include[]=total_count }     # random verification of nothing existing
      expect(customer.subscriptions.total_count).to eq 0   # random expection of nothing is existing
      expect(card.last4).to eq "4242"
      expect(card.exp_month).to eq 9
      expect(card.exp_year).to eq 2019
    end

    it 'retrieves a created token' do
      card_token = StripeMock.generate_card_token(number: '4242424242424242', exp_month: 10, exp_year: 2020)
      token = Stripe::Token.retrieve(card_token)
      expect(token.id).to eq(card_token)
      expect(token.card.last4).to eq '4242'
      expect(token.card.exp_month).to eq 10
      expect(token.card.exp_year).to eq 2020
    end
  end

  describe 'Stripe::Token' do
    # currently checking live key arrangement and its running with $ rspec -t live
   #it 'generates a card token created from customer' do
    it 'generates a card token created from customer', live: true do
#binding.pry # delete the # to use pry, leaving no space at front of line 
      card_token = StripeMock.generate_card_token({
        source: {
          card_number: '4242424242424242',
          exp_month: 11,
          exp_year: 2019,
        }
      })
      customer = Stripe::Customer.create({})
      customer.source = card_token
      customer.description = 'a StripeMock card from customer'
      customer.save
      expect(card_token).to match /^test_tok/
      expect(customer.email).to eq 'stripe_mock@example.com'
     #customer description is no longer sent back as part of the response
     #expect(customer.description).to eq 'a StripeMock card from customer'
      expect(customer.id).to match /^test_cus/
      expect(customer.object).to match /customer/
      if customer.livemode == false
        expect(customer.livemode).to eq false
      elsif customer.livemode == true
        expect(customer.livemode).to eq true
      end  
      expect(customer.discount).to eq nil
    end
  end

  describe 'error handling' do
    it 'throws an error if neither card nor customer are provided', live: true do
      expect{ Stripe::Token.create }.to raise_error(Stripe::InvalidRequestError, /must supply either a card, customer/)
    end
  end
end