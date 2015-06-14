include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!

RSpec.describe 'User Sign in', :devise do

  before(:each) do
    FactoryGirl.reload 
    user = FactoryGirl.build(:user, email: 'test@example.com')
    user.role = 'admin'
    user.save!
  end

  after(:each) do
    Warden.test_reset!
  end

  it 'cannot sign in if not registered' do
    sign_in('testing@example.com', :'please122')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  it 'can sign in with valid credentials' do
    sign_in('test@example.com', :'please123')
    expect(current_path).to eq '/users'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    expect(page).to have_content 'Signed in successfully.'
  end

  it 'cannot sign in with wrong email' do
    sign_in('invalid@example.com', :'please123')
    expect(page).to have_content 'Invalid email or password.'
  end

  it 'cannot sign in with wrong password' do
    sign_in('test@example.com', :'invalidpass')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end
end