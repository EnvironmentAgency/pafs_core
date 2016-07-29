# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ProjectNavigator
    attr_reader :user

    def initialize(user)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def first_step
      sequence.first
    end

    def next_step(step, project)
      step = sequence.next(step, project)
      return :summary if step.to_s.starts_with? "summary_"
      step
    end

    def last_step
      sequence.last
    end

    def new_blank_project(attrs = {})
      PafsCore::Project.new(attrs)
    end

    def start_new_project(attrs = {})
      # we will need to position a project so that it 'belongs' somewhere
      # and is 'owned' by a user.  I envisage that we would use the
      # current_user passed into the constructor to get this information.
      project = project_service.create_project(attrs)
      Object::const_get("PafsCore::#{sequence.first.to_s.camelcase}Step").new project
    end

    def find(ref_number)
      project_service.find_project(ref_number)
    end

    def search(options = {})
      project_service.search(options)
    end

    def find_project_step(id, step)
      check_step(step.to_sym)
      # retrieve and wrap project
      build_project_step(project_service.find_project(id), step, user)
    end

    def build_project_step(project, step, user)
      # accept a step or a raw project activerecord object
      project = project.project if project.respond_to? :project
      # TODO: check that this user has permission to access this project
      Object::const_get("PafsCore::#{step.to_s.camelcase}Step").new(project, user)
    end

  private
    def sequence
      @sequence ||= define_sequence
    end

    # rubocop:disable Metrics/AbcSize
    def define_sequence
      Dibble.sequence do |s|
        s.add :project_name
        s.add :summary_1
        s.add :project_type
        s.add :summary_2
        s.add :financial_year
        s.add :financial_year_alternative, unless: ->(p) { p.step == :financial_year }
        s.add :summary_3

        s.add :location
        s.add :map
        s.add :summary_4

        s.add :key_dates
        s.add :summary_5

        s.add :funding_sources
        s.add :public_contributors, if: :public_contributions?
        s.add :private_contributors, if: :private_contributions?
        s.add :other_ea_contributors, if: :other_ea_contributions?
        s.add :funding_values
        s.add :funding_values_summary, if: :javascript_disabled?
        s.add :summary_6

        s.add :earliest_start
        s.add :earliest_date, if: :could_start_early?
        s.add :summary_7

        s.add :risks
        s.add :main_risk,
          if: ->(p) { p.selected_risks.count > 1 }
        s.add :flood_protection_outcomes,
          if: ->(p) { p.protects_against_flooding? }
        s.add :flood_protection_outcomes_summary,
          if: ->(p) { p.protects_against_flooding? && p.javascript_disabled? }
        s.add :coastal_erosion_protection_outcomes,
          if: ->(p) { p.protects_against_coastal_erosion? }
        s.add :coastal_erosion_protection_outcomes_summary,
          if: ->(p) { p.protects_against_coastal_erosion? && p.javascript_disabled? }
        s.add :summary_8

        s.add :standard_of_protection_flooding, if: :protects_against_flooding?
        s.add :standard_of_protection_coastal, if: :protects_against_coastal_erosion?
        s.add :summary_9

        s.add :approach
        s.add :summary_10

        s.add :surface_and_groundwater
        s.add :surface_and_groundwater_amount, if: :improve_surface_or_groundwater?
        s.add :improve_spa_or_sac
        s.add :improve_sssi, unless: :improve_spa_or_sac?
        s.add :improve_hpi, unless: ->(p) { p.improve_spa_or_sac || p.improve_sssi }
        s.add :improve_habitat_amount, if: :improves_habitat?
        s.add :improve_river, if: :improves_habitat?
        s.add :improve_river_amount, if: :improve_river?
        s.add :habitat_creation
        s.add :habitat_creation_amount, if: :create_habitat?
        s.add :remove_fish_barrier
        s.add :remove_eel_barrier
        s.add :fish_or_eel_amount, if: :removes_fish_or_eel_barrier?
        s.add :summary_11

        s.add :urgency
        s.add :urgency_details, if: :urgent?
        s.add :summary_12

        s.add :funding_calculator
        s.add :funding_calculator_summary
        s.add :summary_13
      end
    end
    # rubocop:enable Metrics/AbcSize

    def check_step(step)
      raise ActiveRecord::RecordNotFound.new("Unknown step [#{step}]") unless sequence.include? step.to_sym
    end

    def project_service
      @project_service ||= ProjectService.new(user)
    end
  end
end
