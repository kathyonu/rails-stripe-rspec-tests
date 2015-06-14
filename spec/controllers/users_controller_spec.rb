require 'pry'

include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  def valid_session
    valid_session = { user_id: 1 }
  end

  def valid_session2
    valid_session2 = { user_id: 2 }
  end
end

RSpec.describe UsersController, type: :controller do
#  render_views

  before (:each) do
    @user = FactoryGirl.create(:user)
    @user.role = 'admin'
    @users = User.all
  end

  after(:each) do
    Warden.test_reset!
  end

  context "GET #index" do
    it "assigns @users" do
      pending 'this needs work, as we are not providing authorization, customer_id, etc.'
      # to work with actual users visiting the index, they must be authorized and validated
      # we have method in one of the spec/stripe/*_spec.rb files that now covers the entire process 
      # of steps required before we can have a valid Sign in : next step see if i can weave that in here ?
#binding.pry
     # sign_in @user
     # expect(@user.id).to eq 1
     # expect(@user.email).to eq 'test@example.com'
     # expect(@user.persisted?).to eq true
     # expect(@user.customer_id).to_not be nil
     # expect(@user.plan_id).to_not be nil
      visit root_path
     # get :index
     # get :index, { id: @user.id }, valid_session
      expect(current_path).to eq '/'
     # expect('/users').to eq users_path
     # get :show, { id: @user.id }, valid_session
     # expect(current_path).to eq '/users/1'
     # get :index, { id: @user.id }, valid_session
     expect(assigns(:users)).to eq User.all
    end
  end

  context "GET #show" do
    it "is successful" do
      expect(@user._validators?).to eq true
      sign_in @user
      get :show, { id: @user.id }, valid_session
      expect(Rails.logger.info response.body).to eq true
      expect(Rails.logger.warn response.body).to eq true
      expect(Rails.logger.debug response.body).to eq true
      expect(response).to be_success
    end

    it "finds the right user" do
      user = FactoryGirl.create(:user, email: 'newuser@example.com')
      user.role = 'admin'
      user.save
      sign_in @user
      get :show, { id: user.id }, valid_session2
      expect(response).to be_success
    end
  end
end