# frozen_string_literal: true
include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do
  def valid_attributes
    @valid_attributes = {
      art_title: 'Awareness',
      art_description: 'Awareness',
      art_image_url: 'awareness.jpg',
      art_size: '11 x 17',
      art_thumb_url: 'awareness.thumb.jpg',
      artist_email: 'example@example.com',
      artist_name: 'Art Tester',
      artist_quote: 'Sweet',
      creation_date: '2014',
      creation_time: '1 year',
      print_cost: '4.00',
      print_sale: '40.00',
      print_ship: '4.00',
      repro_cost: '44.00',
      repro_sale: '444.00',
      repro_ship: '40.00'
    }
  end
end

feature 'Art management' do
  before(:each) do
    @user = FactoryGirl.build(:user)
    @user.add_role 'admin'
    @user.save!
    @users = User.all
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'Admin user creates a new art' do
    # user must be admin authorized
    signin(@user.email, @user.password)
    visit '/arts/new'
    expect(current_path).to eq '/arts/new'
    fill_in 'Art title', with: 'mother'
    fill_in 'Art image url', with: '_mother.jpg'
    click_button 'Create Art'
    expect(current_path).to eq '/arts/1'
    expect(page).to have_text('This is the MOTHER Star Art.')
  end

  scenario 'created art redirects to art_url(@art)' do
    signin(@user.email, @user.password)
    visit '/arts/new'
    expect(current_path).to eq '/arts/new'
    fill_in 'Art title', with: 'mother'
    fill_in 'Art image url', with: '_mother.jpg'
    click_button 'Create Art'

    @art = Art.last
    expect(current_path).to eq '/arts/1'
    expect(current_url).to eq art_url(@art)
    expect(page).to have_text('This is the MOTHER Star Art.')
  end
end
