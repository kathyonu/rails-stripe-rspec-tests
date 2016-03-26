# frozen_string_literal: true
RSpec.describe HomeController, type: :view do
  describe 'GET /how_to' do
    it 'should be successful' do
      visit home_how_to_path
      expect(response).to be
      expect(page).to have_content 'Silver members will see this links bar on their pages'
    end
  end

  describe 'GET /home' do
    it 'should be successful' do
      visit home_path
      expect(page).to have_content 'Sequencing the English Language'
      expect(response).to render_template('home/index')
    end
  end
end
