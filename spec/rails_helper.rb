# frozen_string_literal: true
# Execute with --enable-frozen-string-literal-debug flag
# ruby --enable-frozen-string-literal-debug script.rb

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

require 'capybara/rails'
require 'capybara/rspec'
require 'factory_girl_rails'
require 'rspec/mocks'
require 'stripe_mock'
require 'stripe_mock/server'
require 'email_spec'
require 'sucker_punch'
require 'thin'
# ARGV = [] # Reset ARGV so Dante will quit using rspec params : ingore the warning for now.
# StripeMock.spawn_server # : Note, leaving uncommented to test our live tests : no longer required.
# Note of 20160320 : it appears this is again resolved, the above two, commented out, have no effect.
# Note of 20150613 : it again appears this spawn_server must be toggled, itself, for live test to run
# StripeMock.spawn_server : Note it appears this command above must be commented out when running $ rspec -t live

# Reference : http://stackoverflow.com/questions/11770552/how-to-get-rails-logger-printing-to-the-console-stdout-when-running
def log_test(message)
    Rails.logger.info(message)
    puts message
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# Reference : http://stackoverflow.com/questions/8862967/visit-method-not-found-in-my-rspec
# Reference : http://stackoverflow.com/questions/8862967/visit-method-not-found-in-my-rspec
module RSpec
  class Core
    class ExampleGroup
      include Capybara::DSL
      include Capybara::RSpecMatchers
    end
  end
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)

  # If true, the base class of anonymous controllers will be inferred automatically.
  # This will be the default behavior in future versions of rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  # If you're not using ActiveRecord, or you'd prefer not to run each of your examples
  # within a transaction, remove the following line or assign false instead of true.
  config.use_transactional_fixtures = false

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # this RSpec method was added per Terminal response on 20140628
  # check this method next time in raise_errors, any change ? 20150611
  config.raise_errors_for_deprecations!

  config.include Warden::Test::Helpers
  config.include Devise::TestHelpers, type: :controller
end
