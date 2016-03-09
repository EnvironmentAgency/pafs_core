# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
# Class for setting configuration options in this engine. See e.g.
# http://stackoverflow.com/questions/24104246/how-to-use-activesupportconfigurable-with-rails-engine
#
# To override default config values, for example in an initaliser, use e.g.:
#   PafsCore.configure do |config|
#    config.exemptions_expire_after_duration = 3.years - 1.day
#   end
# To access configuration settings use e.g.
#   PafsCore.config.banner_feedback_uri
#
module PafsCore
  class Configuration
    include ActiveSupport::Configurable

    # Define accessors and optional defaults
    config_accessor(:exemptions_expire_after_duration) { 3.years - 1.day }
    config_accessor(:complete_page_feedback_uri)
    config_accessor(:banner_feedback_uri)
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield config
  end
end
