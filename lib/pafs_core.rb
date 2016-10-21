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
require "pafs_core/risks"
require "pafs_core/standard_of_protection"
require "pafs_core/environmental_outcomes"
require "pafs_core/financial_year"
require "pafs_core/outcomes"
require "pafs_core/sql_columns_for_spreadsheet"
require "pafs_core/spreadsheet_column_headers"
require "pafs_core/spreadsheet_column_order"
require "pafs_core/spreadsheet_custom_styles"
require "pafs_core/file_types"
require "core_ext/time/financial"
require "core_ext/date/financial"

Time.include CoreExtensions::Time::Financial
Date.include CoreExtensions::Date::Financial

module PafsCore
end
