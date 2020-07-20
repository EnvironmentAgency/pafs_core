# frozen_string_literal: true

require "pafs_core/engine"
require "pafs_core/configuration"
require "pafs_core/rfcc_codes"
require "pafs_core/coastal_groups"
require "pafs_core/standard_of_protection"
require "pafs_core/project_types"
require "pafs_core/urgency"
require "pafs_core/errors"
require "pafs_core/form_builder"
require "pafs_core/funding_sources"
require "pafs_core/funding_values"
require "pafs_core/risks"
require "pafs_core/standard_of_protection"
require "pafs_core/environmental_outcomes"
require "pafs_core/carbon"
require "pafs_core/confidence"
require "pafs_core/financial_year"
require "pafs_core/outcomes"
require "pafs_core/sql_columns_for_spreadsheet"
require "pafs_core/spreadsheet_column_headers"
require "pafs_core/spreadsheet_column_order"
require "pafs_core/spreadsheet_custom_styles"
require "pafs_core/grid_reference"
require "pafs_core/file_types"
require "pafs_core/file_storage"
require "pafs_core/files"
require "pafs_core/fcerm1"
require "pafs_core/email"
require "pafs_core/custom_headers"
require "pafs_core/mapper/funding_calculator_maps/base"
require "pafs_core/mapper/funding_calculator_maps/v8"
require "pafs_core/mapper/funding_calculator_maps/v9"
require "pafs_core/funding_calculator_version"
require "pafs_core/data_migration/remove_duplicate_states"
require "pafs_core/data_migration/update_areas"
require "pafs_core/data_migration/update_projects"
require "pafs_core/data_migration/export_to_pol"
require "pafs_core/data_migration/generate_funding_contributor_fcerm"
require "pafs_core/data_migration/move_funding_sources"
require "pafs_core/data_migration/update_pol_submission_date"
require "pafs_core/mapper/fcerm"
require "pafs_core/mapper/funding_sources"
require "pafs_core/mapper/partnership_funding_calculator"
require "pafs_core/calculator_maps/base"
require "pafs_core/calculator_maps/v8"
require "pafs_core/calculator_maps/v9"
require "pafs_core/pol/azure_oauth"
require "pafs_core/pol/azure_vault_client"
require "pafs_core/pol/archive"
require "pafs_core/pol/submission"
require "core_ext/time/financial"
require "core_ext/date/financial"

Time.include CoreExtensions::Time::Financial
Date.include CoreExtensions::Date::Financial

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
