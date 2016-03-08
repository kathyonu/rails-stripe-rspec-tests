require 'stripe_mock'
include Warden::Test::Helpers
Warden.test_mode!

describe 'Subscription API', live: true do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it 'allows customer to cancel subscription' do
    card_token = StripeMock.generate_card_token(
      last4: '4242',
      exp_month: 11,
      exp_year: 2017
    )
    customer = Stripe::Customer.create(
      email: 'cancelsub@example.com',
      source: card_token,
      description: 'a customer cancellation'
    )
    user = FactoryGirl.create(:user, email: 'cancelsub@example.com')
    customer = Stripe::Customer.retrieve(customer.id)
    user.customer_id = customer.id
    expect(user.email).to eq customer.email
    expect(user.customer_id).to eq customer.id
    expect(customer.sources.data[0].last4).to eq '4242'
    expect(customer.sources.data[0].exp_month).to eq 11
    expect(customer.sources.data[0].exp_year).to eq 2017

    # creating plan
    plan = stripe_helper.create_plan(id: 'my_plan', amount: 1500)
    # The above line replaces the following:
    # plan = Stripe::Plan.create(
    #   :id => 'my_plan',
    #   :name => 'StripeMock Default Plan ID',
    #   :amount => 1500,
    #   :currency => 'usd',
    #   :interval => 'month'
    # )
    expect(plan.id).to eq('my_plan')
    expect(plan.amount).to eq(1500)

    # add subscribing to subscription
    charge = Stripe::Charge.create(
      {
        amount: 1500,
        currency: 'usd',
        interval: 'month',
        plan: 'silver',
        customer: customer.id,
        description: 'a charge with a specific card'
      }, {
      idempotency_key: '95ea4310438306ch'
      }
    )
    card_token = customer.sources.data[0].id
    charge = Stripe::Charge.retrieve(charge.id)
    customer = Stripe::Customer.retrieve(customer.id)
    customer.subscriptions.create(plan: plan.id)
    expect(card_token).to match(/^test_cc/)
    expect(charge.id).to match(/^test_ch/)
    expect(customer.id).to match(/^test_cus/)
    expect(customer.sources.data[0].id).to match(/^test_cc/)
    expect(customer.sources.data.length).to eq 1
    expect(customer.sources.data[0].id).not_to be_nil
    expect(customer.sources.data[0].last4).to eq '4242'

    customer.subscriptions.create(plan: 'my_plan')
    expect(customer.subscriptions[:url]).to match(%r{/v1/customers/test_cus_3/subscriptions})

    customer = Stripe::Customer.retrieve(customer.id)
    expect(customer.subscriptions.data[0].id).to match(/^test_su/)
    expect(customer.subscriptions.data[0].status).to eq 'active'

    subscription = customer.subscriptions.data[0]
    subscription.delete
    customer = Stripe::Customer.retrieve(customer.id)
    customer.subscriptions.data[0].delete
    expect(customer.subscriptions.data[0].status).to eq 'canceled'
  end

  it 'allows customer to delete their account' do
    card_token = stripe_helper.generate_card_token(
      last4: '4242',
      exp_month: 11,
      exp_year: 2017
    )
    customer = Stripe::Customer.create(
      email: 'cancelcus@example.com',
      source: card_token,
      description: 'a customer cancellation'
    )
    user = FactoryGirl.create(:user, email: 'cancelcus@example.com')
    customer = Stripe::Customer.retrieve(customer.id)
    user.customer_id = customer.id
    expect(user.customer_id).to eq customer.id
    expect(user.email).to eq customer.email

    # creating plan
    plan = stripe_helper.create_plan(id: 'my_plan', amount: 1500)
    expect(plan.id).to eq('my_plan')
    expect(plan.amount).to eq(1500)

    # add subscribing to subscription
    charge = Stripe::Charge.create({
      amount: 1500,
      currency: 'usd',
      interval: 'month',
      customer: customer.id,
      description: 'a charge with a specific card'
      },
    {
      idempotency_key: '95ea4310438306ch'
    })
    card_token = customer.sources.data[0].id
    charge = Stripe::Charge.retrieve(charge.id)
    customer = Stripe::Customer.retrieve(customer.id)
    expect(card_token).to match(/^test_cc/)
    expect(charge.id).to match(/^test_ch/)
    expect(customer.id).to match(/^test_cus/)
    expect(customer.sources.data.length).to eq 1
    expect(customer.sources.data[0].id).to match(/^test_cc/)
    expect(customer.sources.data[0].last4).to eq '4242'
    expect(customer.sources.data[1]).to be nil
    customer.delete
    expect(customer.id).to match(/^test_cus/)
    expect(customer.deleted).to be true
  end

  it 'allows customer with two subscriptions to cancel one' do
    card_token = StripeMock.generate_card_token(last4: '4242', exp_month: 11, exp_year: 2018)
    customer = Stripe::Customer.create(
      email: 'cancel@example.com',
      source: card_token,
      description: 'a customer cancellation'
    )
    user = FactoryGirl.create(:user, email: 'cancelone@example.com')
    customer = Stripe::Customer.retrieve(customer.id)
    user.customer_id = customer.id
    expect(user.customer_id).to eq customer.id

    card_token = stripe_helper.generate_card_token(
      last4: '4242',
      exp_month: 11,
      exp_year: 2019
    )
    plan = stripe_helper.create_plan(id: 'my_plan', amount: 1500)
    expect(plan.id).to eq 'my_plan'
    expect(plan.amount).to eq 1500

    charge = Stripe::Charge.create({
      amount: 1500,
      currency: 'usd',
      interval: 'month',
      customer: customer.id,
      description: 'a charge with a specific card'
    }, {
      idempotency_key: '95ea4310438306ch'
    })
    card_token = customer.sources.data[0].id
    charge = Stripe::Charge.retrieve(charge.id)
    customer = Stripe::Customer.retrieve(customer.id)
    expect(card_token).to match(/^test_cc/)
    expect(charge.id).to match(/^test_ch/)
    expect(customer.id).to match(/^test_cus/)
    expect(customer.sources.data[0].id).to match(/^test_cc/)
    expect(customer.sources.data.length).to eq 1
    expect(customer.sources.data[0].id).not_to be_nil
    expect(customer.sources.data[0].last4).to eq '4242'
    customer.delete
    expect(customer.id).to match(/^test_cus/)
    expect(customer.deleted).to be true
    card_token = stripe_helper.generate_card_token(
      last4: '4242',
      exp_month: 11,
      exp_year: 2020
    )
    customer = Stripe::Customer.create(
      email: 'cancelcus@example.com',
      source: card_token,
      description: 'a customer cancellation'
    )
    customer = Stripe::Customer.retrieve(customer.id)
    expect(customer.id).to match(/^test_cus/)

    plan = stripe_helper.create_plan(id: 'my_new_plan', amount: 2500)
    expect(plan.id).to eq 'my_new_plan'
    expect(plan.amount).to eq 2500

    charge = Stripe::Charge.create({
      amount: 2500,
      currency: 'usd',
      interval: 'month',
      customer: customer.id,
      description: 'a charge with a specific card'
    }, {
      idempotency_key: '95ea4310438306ch'
    })
    card_token = customer.sources.data[0].id
    charge = Stripe::Charge.retrieve(charge.id)
    customer = Stripe::Customer.retrieve(customer.id)
    expect(card_token).to match(/^test_cc/)
    expect(charge.id).to match(/^test_ch/)
    expect(customer.id).to match(/^test_cus/)
    expect(customer.sources.data[0].id).to match(/^test_cc/)
    expect(customer.sources.data[0].id).not_to be_nil
    expect(customer.sources.data[0].last4).to eq '4242'
    expect(customer.sources.data.length).to eq 1

    customer.delete
    expect(customer.id).to match(/^test_cus/)
    expect(customer.deleted).to be true
  end

  it 'creates a plan, a customer, add a new card', live: true do
    Stripe::Plan.create(
      id: 'platinum',
      amount: 900,
      currency: 'usd',
      interval: 'month',
      name: 'Platinum'
    )
    customer_attributes = {
      email: 'test@test.com',
      source: stripe_helper.generate_card_token(
        last4: '1881',
        exp_month: 11,
        exp_year: 2021,
        description: 'entering my card number'
      )
    }
    customer = Stripe::Customer.create(customer_attributes)
    subscription = customer.subscriptions.create(plan: 'platinum', prorate: true)
    source = customer.sources.retrieve(customer.default_source)
    expect(customer.id).to match(/^test_cus_3/)
    expect(subscription.id).to match(/^test_su_4/)
    expect(source.id).to match(/^test_cc_2/)

    customer = Stripe::Customer.retrieve(customer.id)
    expect(customer.id).to match(/^test_cus_3/)
    expect(customer.sources.first.id).to match(/^test_cc_2/)
    expect(customer.sources.data.first.last4).to eq '1881'
    expect(customer.subscriptions.first.id).to match(/^test_su_4/)
    expect(customer.subscriptions.data.first.id).to match(/^test_su_4/)

    customer.subscriptions { include[] = data }
    customer.subscriptions.data { include[] = plans }
    expect(customer.subscriptions.first.plan.name).to eq 'Platinum'
    expect(customer.subscriptions.first.id).to match(/^test_su_4/)
    expect(customer.subscriptions.first.customer).to match(/^test_cus_3/)
    expect(customer.subscriptions.first.plan.id).to eq 'platinum'
    expect(customer.sources.total_count).to eq 1

    new_card_token = stripe_helper.generate_card_token(
      last4: '4242',
      exp_month: 11,
      exp_year: 2022,
      description: 'entering my second new card'
    )
    customer.sources.create(source: new_card_token)
    # Note of 20151118 : this has been resolved, gem updated.
    # customer.save # used to fail with TypeError: 0 is not a symbol
    # customer.save # now it fails with removal of sources.data : 20151122
    twocardcustomer = Stripe::Customer.retrieve(customer.id)
    expect(twocardcustomer.sources.data.count).to eq 2
    expect(twocardcustomer.id).to match(/^test_cus_3/)
    expect(twocardcustomer.email).to eq 'test@test.com'
    expect(twocardcustomer.object).to eq 'customer'
    expect(twocardcustomer.livemode).to eq false
    expect(twocardcustomer.description).to eq 'an auto-generated stripe customer data mock'
    expect(twocardcustomer.sources.first.id).to match(/^test_cc_2/)
    expect(twocardcustomer.sources.data.first.id).to match(/^test_cc_2/)
    expect(twocardcustomer.sources.data.second.id).to match(/^test_cc_7/)
    expect(twocardcustomer.sources.data[0].last4).to eq '1881'
    expect(twocardcustomer.sources.data[0].exp_month).to eq 11
    expect(twocardcustomer.sources.data[0].exp_year).to eq 2021
    expect(twocardcustomer.sources.data[1].last4).to eq '4242'
    expect(twocardcustomer.sources.data[1].exp_month).to eq 11
    expect(twocardcustomer.sources.data[1].exp_year).to eq 2022
    expect(twocardcustomer.default_source).to match(/^test_cc_2/)
  end
end
