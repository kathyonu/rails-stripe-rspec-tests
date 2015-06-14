# Source Reference : https://gist.github.com/jsteiner/8362013
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
 
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end
 
  config.before(:each, js: true) do
     DatabaseCleaner.strategy = :truncation
  end
 
  config.before(:each, job: true) do
     DatabaseCleaner.strategy = :truncation
  end
 
  config.before(:each) do
    DatabaseCleaner.start
  end
 
 #config.append_after(:each) do  # study this
  config.after(:each) do
    DatabaseCleaner.clean
  end
end