source 'https://rubygems.org'

# Declare your gem's dependencies in pafs_core.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem "dibble", "~> 0.1",
  git: "https://github.com/tonyheadford/dibble",
  branch: "develop"

group :development, :test do
  gem 'byebug'
  gem 'pry'
  gem 'guard-rspec', require: false
end

group :test do
  gem "codeclimate-test-reporter", require: false
end

gem 'cumberland', git: 'https://github.com/EnvironmentAgency/cumberland'
# gem 'rack-cors'
# gem 'axlsx', "~> 2.1.0.pre"
# gem 'axlsx_rails'
# gem 'roo', '~> 2.4.0'
