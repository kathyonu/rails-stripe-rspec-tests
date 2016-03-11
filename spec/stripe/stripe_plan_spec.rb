require 'stripe_mock'
include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do
  def gen_card_tk
    stripe_helper.generate_card_token(last4: '4242')
  end

  def new
    @stripe_plan = Stripe::Plan.retrieve('plan_musician')

    respond_to do |format|
      format.html
    end
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  def valid_session
    valid_session = { user_id: 1 }
  end
end

describe 'Plan API', live: true, focus: true do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it 'creates a stripe plan' do
    plan = stripe_helper.create_plan(id: 'my_plan', amount: 1500)
    # The above line creates / mocks / replaces the following:
    # plan = Stripe::Plan.create(
    #   id: 'my_plan',
    #   name: 'StripeMock Default Plan ID',
    #   amount: 1500,
    #   currency: 'usd',
    #   object: 'plan',
    #   livemode: false,
    #   interval: 'month',
    #   interval_count: 1,
    #   trial_period_days: null
    # )
    # any variable of plan can now be tested
    expect(plan.id).to eq 'my_plan'
    expect(plan.amount).to eq 1500
    expect(plan.currency).to eq 'usd'
    expect(plan.interval).to eq 'month'
    expect(plan.interval_count).not_to eq 2
    expect(plan.trial_period_days).not_to eq 7
  end

  # stripe-ruby-mock upgrade creation 201507112200
  it 'creates a different stripe plan' do
    planb = stripe_helper.create_plan(
      id: 'your_plan',
      amount: 500,
      name: 'Your Plan Name',
      trial_period_days: 14
    )
    expect(planb.id).to eq 'your_plan'
    expect(planb.amount).to eq 500
    expect(planb.currency).to eq 'usd'
    expect(planb.interval).to eq 'month'
    expect(planb.interval_count).not_to eq 0
    expect(planb.trial_period_days).to eq 14
  end
end
