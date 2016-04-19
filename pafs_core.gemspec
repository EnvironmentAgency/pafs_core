$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pafs_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pafs_core"
  s.version     = PafsCore::VERSION
  s.authors     = ["Digital Services Team, Environment Agency"]
  s.email       = ["dst@environment-agency.gov.uk"]
  s.homepage    = "https://github.com/EnvironmentAgency"
  s.summary     = "Project Application and Funding Service core shared functionality"
  s.description = "Project Application and Funding Service core shared functionality"
  s.license     = "The Open Government Licence (OGL) Version 3"

  s.files = Dir["{app,config,db,lib}/**/*", "spec/factories/**/*", "spec/support/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.5.1"
  s.add_dependency "clamav-client", "~> 3.0"
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
  # s.add_development_dependency "ffaker"

end
