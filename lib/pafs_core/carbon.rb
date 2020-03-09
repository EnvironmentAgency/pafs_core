# frozen_string_literal: true

module PafsCore
  module Carbon
    delegate :carbon_cost_build, :carbon_cost_build=,
             :carbon_cost_operation, :carbon_cost_operation=,
             :carbon_sequestered, :carbon_sequestered=,
            to: :project
  end
end
