# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
