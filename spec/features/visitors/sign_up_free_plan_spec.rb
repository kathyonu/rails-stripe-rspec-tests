# frozen_string_literal: true
# 20150610 : beginnings of Free Plan tests
describe 'Free Plan' do
  describe 'Visitor Sign up' do
    it 'visitor arrives on Free Plan Content page' do
      visit content_gratis_path
      expect(current_path).to eq '/content/gratis'
    end

    # many of these tests will be moved to other files
    # it 'visitor can see Free Plan link' do
    #   pending 'write the code'
    # end

    # it 'visitor can click on Free Plan link' do
    #   pending 'write the code'
    # end

    # it 'visitor arrives on Free Plan Sign up page' do
    #   pending 'write the code'
    # end

    # it 'visitor can see the form to fill in' do
    #   pending 'write the code'
    # end

    # it 'visitor can fill in the form' do
    #   pending 'write the code'
    # end

    # it 'visitor can see the Sign up button' do
    #   pending 'write the code'
    # end

    # it 'visitor can click on the Sign up button' do
    #   pending 'write the code'
    # end

    # it 'visitor arrives on Free Plan Content page' do
    #   visit content_free_path
    #   expect(current_path).to eq '/content/free'
    # end

    # it 'visitor becomes a User upon successful Free Plan Sign up' do
    #   pending 'write the code'
    # end

    # it 'user is assigned the correct Free Plan role.id' do
    #   pending 'write the code'
    # end

    # it 'user is assigned the correct Free Plan plan.id ' do
    #   pending 'write the code'
    # end

    # it 'user can arrive on their account edit page' do
    #   pending 'write the code'
    # end

    # it 'user sees the Edit account link' do
    #   pending 'write the code'
    # end

    # it 'user can click on the Edit account link' do
    #   pending 'write the code'
    # end

    # it 'user arrives on their Edit account page' do
    #   pending 'write the code'
    # end

    # it 'user can see the Change Your Plan button' do
    #   pending 'write the code'
    # end

    # it 'user chooses the Silver Plan selection' do
    #   pending 'write the code'
    # end

    # it 'user is presented with the credit card signup form' do
    #   pending 'write the code'
    # end

    # it 'user can now fill in the required information' do
    #   pending 'write the code'
    # end

    # it 'user can see the Change Plan button' do
    #   pending 'write the code'
    # end

    # it 'user can click on the Change Plan button' do
    #   pending 'write the code'
    # end

    # it 'user credit card information is processed to stripe' do
    #   pending 'write the code'
    # end

    # it 'user form waits for stripe response' do
    #   pending 'write the code'
    # end

    # it 'user form receives StripeToken' do
    #   pending 'write the code'
    # end

    # it 'user information is processed' do
    #   pending 'write the code'
    # end

    # it 'user Plan Change Sign up is successful' do
    #   pending 'write the code'
    # end

    # it 'user is now on the content/silver page' do
    #   pending 'write the code'
    # end
  end
end
