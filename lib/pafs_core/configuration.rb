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
  # Enable the ability to configure the gem from its host app, rather than
  # reading directly from env vars. Derived from
  # https://robots.thoughtbot.com/mygem-configure-block
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end
  end

  def self.configure
    yield(configuration)
  end

  def self.start_airbrake
    DefraRuby::Alert.start
  end

  class Configuration
    include ActiveSupport::Configurable

    # Define accessors and optional defaults
    config_accessor(:exemptions_expire_after_duration) { 3.years - 1.day }
    config_accessor(:complete_page_feedback_uri)
    config_accessor(:banner_feedback_uri)

    def initialize
      configure_airbrake_rails_properties
    end

    # Airbrake configuration properties (via defra_ruby_alert gem)
    def airbrake_enabled=(value)
      DefraRuby::Alert.configure do |configuration|
        configuration.enabled = change_string_to_boolean_for(value)
      end
    end

    def airbrake_host=(value)
      DefraRuby::Alert.configure do |configuration|
        configuration.host = value
      end
    end

    def airbrake_project_key=(value)
      DefraRuby::Alert.configure do |configuration|
        configuration.project_key = value
      end
    end

    def airbrake_blocklist=(value)
      DefraRuby::Alert.configure do |configuration|
        configuration.blocklist = value
      end
    end

    private

    # If the setting's value is "true", then set to a boolean true. Otherwise,
    # set it to false.
    def change_string_to_boolean_for(setting)
      setting = setting == "true" if setting.is_a?(String)
      setting
    end

    def configure_airbrake_rails_properties
      DefraRuby::Alert.configure do |configuration|
        configuration.root_directory = Rails.root
        configuration.logger = Rails.logger
        configuration.environment = Rails.env
      end
    end
  end
end
