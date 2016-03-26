# frozen_string_literal: true
include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!

RSpec.describe Art, :devise, js: true do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @user = FactoryGirl.build(:user, email: 'sequence@example.com')
    @user.add_role 'admin'
    @user.save!
    @users = User.all
    signin('sequence@example.com', 'please123')
  end

  after(:each) do
    Warden.test_reset!
  end

  describe 'arts/index', :devise, type: :view, js: true do
    it 'renders the list of arts' do
      art = FactoryGirl.create(:art)
      @arts = assign(:arts, Art.all)
      visit '/arts'
      expect(art.id).to eq 1
      expect(current_path).to eq '/arts'
      expect(page).to have_content 'mother'
      expect(@arts.count).to eq 1

      visit '/arts'
      expect(current_path).to eq arts_path
      expect(current_path).to eq '/arts'
    end
  end

  describe 'arts/show', type: :view do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @user = FactoryGirl.build(:user, email: 'sequences@example.com')
      @user.add_role 'admin'
      @user.save!
      @users = User.all
    end

    it 'renders the first art in the database' do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      login_as @user
      visit '/arts/new'
      expect(current_path).to eq '/arts/new'
      fill_in 'Art title', with: 'mother'
      fill_in 'Art image url', with: '_mother.jpg'
      click_button 'Create Art'
      @art = Art.first
      @arts = Art.all
      visit "/arts/#{@art.id}"
      expect(page).to have_content 'mother'
      expect(@arts.size).to eq 1
      expect { FactoryGirl.create(:art) }.to change { @arts.count }.from(1).to(2)
      expect { FactoryGirl.create(:art) }.to change { @arts.count }.from(2).to(3)
    end
  end
end
