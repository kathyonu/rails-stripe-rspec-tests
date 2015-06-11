# 20150610 : beginnings of Free Plan tests

describe 'Free Plan' do
  describe 'Visitor Sign up' do
    it 'visitor arrives on a landing page' do
    it 'visitor can see Free Plan link' do
    it 'visitor can click on Free Plan link' do
    it 'visitor arrives on Free Plan Sign up page' do
    it 'visitor can see the form to fill in' do
    it 'visitor can fill in the form' do
    it 'visitor can see the Sign up button' do
    it 'visitor can click on the Sign up button' do
    it 'visitor arrives on Free Plan Content page' do
      visit content_free_path
      expect(current_path).to eq '/content/free’
    end
    it 'visitor becomes a User upon successful Free Plan Sign up' do
    it 'user is assigned the correct Free Plan role.id' do
    it 'user is assigned the correct Free Plan plan.id ' do
    it 'user can arrive on their account edit page' do
    it 'user sees the Edit account link' do
    it 'user can click on the Edit account link' do
    it 'user arrives on their Edit account page' do
    it 'user can see the Change Your Plan button' do
    it 'user chooses the Silver Plan selection' do
    it 'user is presented with the credit card signup form' do
    it 'user can now fill in the required information' do
    it 'user can see the Change Plan button' do
    it 'user can click on the Change Plan button' do
    it 'user credit card information is processed to stripe' do
    it 'user form waits for stripe response' do
    it 'user form receives StripeToken' do
    it 'user information is processed' do
    it 'user Plan Change Sign up is successful' do
    it 'user is now on the content/silver page' do
  end
end