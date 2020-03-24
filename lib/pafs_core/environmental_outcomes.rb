# frozen_string_literal: true

module PafsCore
  module EnvironmentalOutcomes
    delegate :improve_spa_or_sac?,
             :improve_spa_or_sac, :improve_spa_or_sac=,
             :improve_sssi?,
             :improve_sssi, :improve_sssi=,
             :improve_hpi?,
             :improve_hpi, :improve_hpi=,
             :improve_habitat_amount, :improve_habitat_amount=,
             :improve_river?,
             :improve_river, :improve_river=,
             :improve_river_amount, :improve_river_amount=,
             :create_habitat?,
             :create_habitat, :create_habitat=,
             :create_habitat_amount, :create_habitat_amount=,
             :remove_fish_barrier?,
             :remove_fish_barrier, :remove_fish_barrier=,
             :remove_eel_barrier?,
             :remove_eel_barrier, :remove_eel_barrier=,
             :fish_or_eel_amount, :fish_or_eel_amount=,
             to: :project

    def improves_habitat?
      improve_spa_or_sac? || improve_sssi? || improve_hpi?
    end

    def removes_fish_or_eel_barrier?
      remove_fish_barrier? || remove_eel_barrier?
    end
  end
end
