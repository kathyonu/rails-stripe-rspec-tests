# frozen_string_literal: true
require 'stripe_mock'
require 'stripe_mock/server'
include Devise::TestHelpers
include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!
RSpec.configure do
  def setup
    @controller = UsersController.new
  end

  def plan
    @plan = StripeMock.create_test_helper.create_plan(
      amount: 2000,
      interval: 'month',
      name: 'Musician',
      currency: 'usd',
      id: 'musician',
      trial_period_days: nil
    )
    # if Stripe::Plan.retrieve('musician')
    #  @plan = StripeMock.create_test_helper.delete_plan('musician')
    # amount: 900,
    # interval: 'month',
    # name: 'Musician',
    # currency: 'usd',
    # id: 'musician'
    # )
    # expect(@plan).to eq nil
    # expect(plan.deleted).to eq true
    # expect(plan.id).to eq 'musician'
    # @plan = StripeMock.create_test_helper.create_plan(
    # amount: 2000,
    # interval: 'month',
    # name: 'Musician',
    # currency: 'usd',
    # id: 'musician',
    # trial_period_days: nil
    # )
    # else
    # @plan = StripeMock.create_test_helper.create_plan(
    # amount: 2000,
    # interval: 'month',
    # name: 'Musician',
    # currency: 'usd',
    # id: 'musician',
    # trial_period_days: nil
    # )
    # end
  end

  describe UsersController, type: :controller, devise: true, js: true do
    render_views

    before(:each) do
      StripeMock.start
      Warden.test_reset!
      @user = FactoryGirl.build(:user)
      @user.role = 'admin' # using Enum for roles
      # @user.add_role 'admin' # using Ability/CanCanCn
      @user.save!
      @users = User.all
    end

    after(:each) do
      StripeMock.stop
      Warden.test_reset!
    end

     context 'Visit #index' do
      it 'renders the :index view for Admin' do
        sign_in(@user.email, @user.password)
        visit '/users'
        expect(response.status).to eq 200
        expect(current_path).to eq '/users'
        expect(response).to be_success
      end

      it 'populates an array of users' do
        user = FactoryGirl.build(:user, email: 'youare@example.com')
        user.role = 'admin'
        # user.add_role 'admin'
        user.save!
        users = User.all
        expect(users.class).to eq User::ActiveRecord_Relation

        sign_in(user.email, user.password)
        expect(response.status).to eq 200
        expect(response).to be_success
        expect(current_path).to eq '/users'

        visit '/users'
        expect(page).to have_content('Test User')
        expect(page).to have_content('youare@example.com')
      end

      it 'assigns @users' do
        # TODO: this test is not assigning anything as written
        user = FactoryGirl.build(:user, email: 'youare@example.com')
        user.role = 'admin'
        # user.add_role 'admin'
        user.save!

        users = User.all
        expect(users.class).to eq User::ActiveRecord_Relation
        expect(users.size).to eq 2

        sign_in(user.email, user.password)
        expect(User.all.size).to eq 2
        expect(user.id).to eq 2
        expect(user.email).to eq 'youare@example.com'
        expect(user.persisted?).to eq true

        users = User.all
        visit '/users'
        expect(response.status).to eq 200
        expect(current_path).to eq '/users'
        expect(response).to be_success
      end
    end

    context 'GET #show' do
      it 'is successful' do
        user = FactoryGirl.build(:user, email: 'youare@example.com')
        user.role = 'admin'
        # user.add_role 'admin'
        user.save!
        users = User.all
        expect(users.class).to eq User::ActiveRecord_Relation
        expect(user._validators?).to eq true

        sign_in(user.email, user.password)
        expect(current_path).to eq '/users'

        visit '/users/1'
        expect(Rails.logger.info(response.body)).to eq true
        expect(Rails.logger.warn(response.body)).to eq true
        expect(Rails.logger.debug(response.body)).to eq true
        expect(response).to be_success
      end

      it 'finds the right user' do
        user = FactoryGirl.build(:user, email: 'newuser@example.com')
        user.role = 'admin'
        # user.add_role 'admin'
        user.save!
        sign_in(user.email, user.password)
        visit '/users/2'
        expect(response).to be_success
      end
    end
  end
end
