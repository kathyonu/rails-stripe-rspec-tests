# frozen_string_literal: true
module AuthHelper
  def http_login
    user = 'test@example.com'
    pw = 'please123'
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, pw)
  end
end
