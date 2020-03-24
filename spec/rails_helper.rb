# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require File.expand_path("dummy/config/environment", __dir__)

# Prevent database truncation if the environment is production
# abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
# require "capybara/rspec"
require "factory_bot_rails"
require "shoulda-matchers"
require "vcr"
require "webmock/rspec"
require "spec_helper"
require "climate_control"

include ActionDispatch::TestProcess

Rails.backtrace_cleaner.remove_silencers!

# Add additional requires below this line. Rails is not loaded until this point!

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
Dir["./spec/support/**/*.rb"].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

def escape_xpath_quotes(str)
  if str =~ /'/
    %[concat('] + str.gsub(/'/, %(', "'", ')) + %[')]
  else
    %('#{str}')
  end
end

# removes last word part from symbol
# eg. takes :award_contract_year and returns :award_contract
def parent_symbol(s)
  s.to_s.split("_")[0...-1].join("_").to_sym
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = File.join(__dir__, "fixtures")

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.order = "random"

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

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.before(:suite) do
    PafsCore::ReferenceCounter.seed_counters
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_hosts "codeclimate.com"
  config.default_cassette_options = {
    match_requests_on: %i[method host path]
  }
end

WebMock.disable_net_connect!(allow_localhost: true)
