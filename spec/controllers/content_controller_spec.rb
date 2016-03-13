# Devise test helpers
include Warden::Test::Helpers
Warden.test_mode!

RSpec.describe ContentController, type: :controller do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @user.add_role('silver')
    @user.save!
    @users = User.all
  end

  after(:each) do
    FactoryGirl.reload
    Warden.test_reset!
  end

  describe '#authorize' do
    it 'unauthorized user cannot gain access to content' do
      visit '/content/silver'
      expect(current_path).to eq '/users/sign_in'
      expect(response.status).to eq 200
    end
  end

  describe 'GET #silver' do
    it 'returns http success' do
      @user.add_role :silver
      @user.email = 'silver@example.com'
      @user.save!
      login_as @user
      visit '/content/silver'
      expect(current_path).to eq '/content/silver'
      expect(response).to @user.has_role?(:silver) ? be_success : redirect_to(content_silver_path)
    end
  end

  describe 'GET gold' do
    it 'returns http success' do
      @user.add_role :gold
      @user.email = 'gold@example.com'
      @user.save!
      login_as @user
      visit '/content/gold'
      expect(response).to @user.has_role?(:gold) ? be_success : redirect_to(content_gold_path)
    end
  end

  describe 'GET #platinum' do
    it 'returns http success' do
      @user.add_role :platinum
      @user.email = 'platinum@example.com'
      @user.save!
      login_as @user
      visit '/content/platinum'
      expect(response).to @user.has_role?(:platinum) ? be_success : redirect_to(content_platinum_path)
    end
  end

  describe 'GET #board' do
    it 'returns http success' do
      @user.add_role :board
      @user.email = 'board@example.com'
      @user.save!
      login_as @user
      visit '/content/board'
      expect(response).to @user.has_role?(:board) ? be_success : redirect_to(content_board_path)
    end
  end
end
