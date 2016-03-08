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

  # visitor cannot gain access to restricted content
  context 'cannot visit sequences' do
    it 'visitor cannot interact with sequences' do
      visit '/sequences'
      expect(response.status).to eq 200
      expect(current_path).to eq '/users/sign_in'
    end
  end

  # As a new visitor to the site
  # I can arrive on the home page
  # root_path = /visitors/new
  # visitor with email is directed to /visitors/index
  context 'GET #new' do
    it 'success for new visitor arrival' do
      get :new
      expect(response.status).to eq 200
      expect(response.content_type).to eq 'text/html'
      expect(response.header['X-Frame-Options']).to eq 'SAMEORIGIN'
      expect(response.header['X-XSS-Protection']).to eq '1; mode=block'
      expect(response.header['X-Content-Type-Options']).to eq 'nosniff'
      expect(response.header['Content-Type']).to eq 'text/html; charset=utf-8'
      expect(response.request.cookies).to eq({})
      expect(response.request.fullpath).to eq root_path
      expect(response.request.request_method).to eq 'GET'
      expect(response.request.env['QUERY_STRING']).to eq ''
      expect(response.request.env['SCRIPT_NAME']).to eq nil
    end
  end

  # As a new visitor to the site
  # When I enter my email address to receive free ebook
  # Then I am sent to proper page, based on email format and presence
  context 'GET #show the manuscript' do
    it 'success for visitor with email' do
      # method is in spec/support/helpers/session_helpers.rb
      visitor_sign_up_for_ebook('iam@example.com')
      expect(response.status).to eq 200
      expect(response.header['X-Frame-Options']).to eq 'SAMEORIGIN'
      expect(response.header['X-XSS-Protection']).to eq '1; mode=block'
      expect(response.header['X-Content-Type-Options']).to eq 'nosniff'
      expect(response.request.cookies).to eq({})
      expect(current_path).to match(/visitors/)
      # expect(current_path).to eq '/visitors/2'
      # expect(current_path).to eq '/visitors'
    end
  end


    it 'failure for visitor without email' do
      visitor_sign_up_for_ebook('')
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
      page.driver.browser.switch_to.alert.accept
      expect(response.status).to eq 200
      expect(current_path).to eq '/'

      # visitor = FactoryGirl.build(:visitor)
      # visitor.email = ''
      # visitor_sign_up_for_ebook(visitor.email)
      # page.driver.browser.switch_to.alert.accept
      #
      # puts page.driver.browser.switch_to.alert.methods.sort
      # page.driver.browser.switch_to.alert.accept
      # page.driver.browser.switch_to.alert.dismiss
      # page.driver.browser.switch_to.alert.display
      # page.driver.browser.switch_to.alert.pretty_inspect
      # page.driver.browser.switch_to.alert.private_methods
      # page.driver.browser.switch_to.alert.protected_methods
      # page.driver.browser.switch_to.alert.pry  # << lights up pry !!
      # page.driver.browser.switch_to.alert.public_methods
      # page.driver.browser.switch_to.alert.received_message? # it is a method, yet I can't work it
      # page.driver.browser.switch_to.alert.to_json
      # page.driver.browser.switch_to.alert.to_param # it is a method, yet I can't work it
      # page.driver.browser.switch_to.alert.to_query # => "#<Selenium::WebDriver::Alert:0x007ffcea1376c8>"
      # page.driver.browser.switch_to.alert.to_sto_query # => "#<Selenium::WebDriver::Alert:0x007ffcea1376c8>"
      # page.driver.browser.switch_to.alert.to_yaml # => Unreadable Data treasure trove
      # page.driver.browser.switch_to.alert.with_warnings  # it is a method, yet I can't work it
      # expect(response.status).to eq 200
      # expect(current_path).to eq '/'
      # 20160229 : all of a sudden, after the above test, i get this error:
      # Selenium::WebDriver::Error::UnhandledAlertError:
      #  Unexpected modal dialog (text: Hello, please enter your email): "Hello, please enter your email"
      # solved with the simple `click_on 'OK'` after grabbing the response window with :
      # in page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
      # followed by : click_on 'OK'
      expect(response.header['X-Frame-Options']).to eq 'SAMEORIGIN'
      expect(response.request.cookies).to eq({}) # TODO: one day, i shall test my cookies
      expect(response.request.env[:HTTPS]).to eq nil
      expect(response.request.env['action_dispatch.secret_key_base']).to match(/^79cfa.+/)
      expect(response.request.filtered_parameters.count).to eq 0
      expect(response.request.filtered_parameters).to be_a(Hash)
      expect(response.request.request_method).to eq 'GET'
      # puts 'PUTTING OUT RESPONSE: ' + response
      # Rails.logger.info(response)
      # stray animal : `if server_ip = '127.0.0.1'`
    end

    it 'failure for visitor with improper email format' do
      visitor = FactoryGirl.build(:visitor)
      visitor.email = 'broken@example'
      expect { visitor.save! }.to raise_error { |e|
        expect(e).to be_a ActiveRecord::RecordInvalid
        expect(e.message).to match(/Validation failed: Email is invalid/i)
        expect(e.message).to include 'Validation failed: Email is invalid'
      }
    end
  end
end
