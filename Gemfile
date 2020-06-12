# frozen_string_literal: true

source "https://rubygems.org"

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
gem "sprockets-rails"

gem "rubyzip"

group :development, :test do
  gem 'rake', '< 11.0'
  gem "byebug"
  gem "climate_control"
  gem "defra_ruby_style"
  gem "guard-rspec", require: false
  gem "json_schemer"
  gem "pry"
  gem "rails-controller-testing"
  gem "rails5-spec-converter"
  gem "transpec"
end

group :test do
  gem "codeclimate-test-reporter", "~> 0.6", require: false
  gem "database_cleaner"
  gem "memory_profiler"
end
