source 'https://rubygems.org'

# Declare your gem's dependencies in pafs_core.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# Once the development stable we should move this to the gemspec
gem 'digital_services_core',
    git: 'https://github.com/EnvironmentAgency/digital-services-core',
    branch: 'develop'

group :development, :test do
  gem 'byebug'
  gem 'pry'
  gem 'guard-rspec', require: false
end

group :test do
  gem 'sinatra'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]

