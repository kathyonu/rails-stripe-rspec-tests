# frozen_string_literal: true
include Warden::Test::Helpers
Warden.test_mode!

describe Visitor, type: :model, js: true do
  before(:each) do
    visitor1 = Visitor.create!(email: 'first@example.com')
    visitor2 = Visitor.create!(email: 'second@example.com')
    @visitors = Visitor.all
    @visitor_1_id = visitor1.id
    @visitor_2_id = visitor2.id
    @visitor = FactoryGirl.create(:visitor)
  end

  after(:each) do
    Warden.test_reset!
  end

  it 'has a valid factory' do
    expect(build(:visitor)).to be_valid
  end

  it 'creates three visitors with email' do
    expect(@visitor_1_id).to eq 1
    expect(@visitor_2_id).to eq 2
    expect(@visitor.id).to eq 3
    expect(@visitors.count).to eq 3
  end

  it '#subscribe' do
    # Gibbon will not accept and process an @example.com address.
    # visitor.email = 'yours@yourdomain.com'
    visitor = FactoryGirl.build(:visitor, email: 'yours@example.com')
    # visitor.email = 'yours@yourdomain.com'
    expect(visitor.persisted?).to be false
    expect(visitor.save!).to be true
    expect(visitor.persisted?).to be true
    expect(visitor.email).to eq 'yours@example.com'
  end

  # as designed, this test is snagged, stopped and processed by
  # app/assets/javascripts/visitor-email-submission.js
  it '#subscribe fails if email is improperly formatted' do
    visitor = FactoryGirl.build(:visitor, email: 'faker@rekafcom')
    # Gibbon will not accept and process an @example.com address.
    # visitor.email = 'invalidemail@yourdomain'
    # visitor.email = 'validemail@exampl'
    # bind ing.pry
    # response = gb.lists.subscribe( id: mailchimp_list_id, email: {email: email} )
    # puts response
    expect(visitor.save).not_to be true
    # expect(visitor.subscribe).not_to be true
    expect(current_path).not_to eq '/visitors'
  end

  it 'with no email entry is returned to home page' do
    visitor = FactoryGirl.build(:visitor, email: '')
    # next expect block is stopped by app/assets/javascripts/visitor-email-submission.js
    expect { visitor.save! }.to raise_error { |e|
      expect(e).to be_an ActiveRecord::RecordInvalid
      # expect(e.http_status).to eq 402
      # (e.code).to eq 'say_what'
    }
  end
end
