# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "pafs_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pafs_core"
  s.version     = PafsCore::VERSION
  s.authors     = ["CIS Solutions Delivery, Environment Agency"]
  s.email       = ["tony.headford@environment-agency.gov.uk"]
  s.homepage    = "https://github.com/EnvironmentAgency"
  s.summary     = "Project Application and Funding Service core shared functionality"
  s.description = "Project Application and Funding Service core shared functionality"
  s.license     = "The Open Government Licence (OGL) Version 3"

  s.files = Dir["{app,config,db,lib}/**/*", "spec/factories/**/*", "spec/support/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "aws-sdk-s3", "~> 1.67"
  s.add_dependency "bstard"
  s.add_dependency "clamav-client"
  s.add_dependency "faraday"
  s.add_dependency "kaminari"
  s.add_dependency "nokogiri"
  s.add_dependency "rack-cors"
  s.add_dependency "rails", ">= 5.2.0", "< 6"
  s.add_dependency "roo"
  s.add_dependency "rubyXL"
  s.add_dependency "secure_headers"

  # Provided by GDS - Template gives us a master layout into which
  # we can inject our content using yield and content_for
  s.add_dependency "govuk_template"
  s.add_dependency "govuk_frontend_toolkit"
  s.add_dependency "govuk_elements_rails"

  s.add_development_dependency "capybara"
  s.add_development_dependency "climate_control"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "dotenv"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "overcommit"
  s.add_development_dependency "pg", "0.20.0"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
end
