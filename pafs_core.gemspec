$:.push File.expand_path("../lib", __FILE__)

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

  s.add_dependency "rails", "~> 4.2.5.1"
  s.add_dependency "clamav-client", "~> 3.0"
  s.add_dependency "aws-sdk", "~> 2"
  s.add_dependency "rack-cors"
  s.add_dependency "axlsx", "~> 2.1.0.pre"
  s.add_dependency "axlsx_rails"
  s.add_dependency "roo", "~> 2.4.0"
  s.add_dependency "bstard"
  s.add_dependency "faraday"
  #s.add_dependency "axlsx"
  #s.add_dependency "axlsx_rails"
  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails", "~> 4.0"
  s.add_development_dependency "shoulda-matchers", "~> 3.1"
  s.add_development_dependency "capybara"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "dotenv"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "overcommit"
  s.add_development_dependency "vcr", "~> 3.0"
  s.add_development_dependency "webmock", "~> 1.24"
  # s.add_development_dependency "ffaker"
end
