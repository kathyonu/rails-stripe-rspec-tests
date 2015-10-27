include Warden::Test::Helpers
Warden.test_mode!

describe VisitorsController do
  after(:each) do
    Warden.test_reset!
  end

  context 'GET #index' do
    it 'success for visitor with email' do
      get :index
      expect(response.status).to eq 200
      visit '/visitors'
      expect(current_path).to eq '/visitors'
    end

    it 'failure for visitor without email' do
      visitor = FactoryGirl.build(:visitor)
      visitor.email = 'broken@example'
      expect { visitor.save! }.to raise_error { |e|
        expect(e).to be_a ActiveRecord::RecordInvalid
        expect(e.message).to match(/Validation failed: Email is invalid/i)
        expect(e.message).to include 'Validation failed: Email is invalid'
      }
    end
  end

  context 'cannot visit sequences' do
    it 'visitor cannot interact with sequences' do
      visit '/sequences'
      expect(response.status).to eq 200
      expect(current_path).to eq '/users/sign_in'
    end
  end
end
