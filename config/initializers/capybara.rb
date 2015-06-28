Capybara.configure do |config|
  config.run_server = true
  config.current_driver = :selenium
  #config.app = "127.0.0.1"
  #config.app = "Application"
  #config.app = "Memberships"
  #config.app = "example.com"
  #config.app_host = "http://www.example.com"
  #config.app_host = "http://site.com/#{@test_url}"
end