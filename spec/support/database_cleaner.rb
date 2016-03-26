# frozen_string_literal: true
# Source Reference : https://gist.github.com/jsteiner/8362013
# also : http://stackoverflow.com/questions/4869020/rails-test-database-wont-wipe
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    # DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    # if example.metadata[:js] || example.metadata[:type] == :feature
    # DatabaseCleaner.strategy = :deletion
    # else
    DatabaseCleaner.strategy = :transaction
    #  DatabaseCleaner.start
    # end
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
    # DatabaseCleaner.strategy = :deletion
  end

  config.before(:each, job: true) do
    DatabaseCleaner.strategy = :truncation
    # DatabaseCleaner.strategy = :deletion
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  # config.after(:each) do
  config.append_after(:each) do # testing this
    DatabaseCleaner.clean
  end
end
