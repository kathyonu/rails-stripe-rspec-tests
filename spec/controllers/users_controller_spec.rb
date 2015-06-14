include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  def valid_session
    valid_session = { "user_id" => 1 }
  end

  def valid_session2
    valid_session2 = { "user_id" => 2 }
  end
end

RSpec.describe UsersController, type: :controller do
#  render_views

  before (:each) do
    @arts = Art.all
    @user = FactoryGirl.create(:user)
    @user.add_role("admin")
  end

  after(:each) do
    Warden.test_reset!
  end

  describe "GET #index" do
    it "assigns @arts" do
       visit arts_path
       expect(current_path).to eq('/arts')
       expect('/arts').to eq(arts_path)
       expect(assigns(:arts)).to eq(Art.first)
    end
  end

  describe "GET #show" do
    it "is successful" do
      expect(@user._validators?).to eq true
      sign_in @user
      get :show, { :id => @user.id }
      expect(Rails.logger.info response.body).to eq true
      expect(Rails.logger.warn response.body).to eq true
      expect(Rails.logger.debug response.body).to eq true
      expect(response).to be_success
    end

    it "finds the right user" do
      user = FactoryGirl.create(:user, email: 'newuser@example.com')
      user.add_role('admin')
      user.save
      sign_in @user
      get :show, { :id => user.id }, valid_session2
    end
  end
end