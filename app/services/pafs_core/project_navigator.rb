# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ProjectNavigator
    # add 'pages' or 'steps' to the STEPS list in order
    # NOTE: STEPS.first and STEPS.last are used to determine the start
    # and end points for the user's journey (although we can change this)
    STEPS = [:project_name,
             :project_type,
             :financial_year,
             :financial_year_alternative,
             :key_dates,

             :funding_sources,
             :funding_values,
             :funding_values_summary, # not in nav - accessible only when no js following :funding_values
             :earliest_start,
             :earliest_date, # not in nav - accessible by choosing 'Yes' on :earliest_start
             :location,
             :map,
             :benefit_area_file_summary,

             :risks,
             :main_risk, # not in nav - accessible following :risks
             :flood_protection_outcomes,
             :flood_protection_outcomes_summary, # not in nav
             :coastal_erosion_protection_outcomes,
             :coastal_erosion_protection_outcomes_summary, # not in nav
             :standard_of_protection,
             :standard_of_protection_coastal, # not in nav - follows :standard_of_protection
             :approach,

             :surface_and_groundwater,
             :surface_and_groundwater_amount, # not in nav
             :improve_river, # not in nav
             :improve_spa_or_sac,
             :improve_sssi, # not in nav
             :improve_hpi, # not in nav
             :improve_habitat_amount, # not in nav
             :improve_river_amount, # not in nav
             :habitat_creation,
             :habitat_creation_amount, # not in nav
             :remove_fish_barrier,
             :remove_eel_barrier, # not in nav
             :fish_or_eel_amount, # not in nav

             :urgency,
             :urgency_details, # not in nav - follows :urgency

             :funding_calculator,
             :funding_calculator_summary # not in nav
    ].freeze

    attr_reader :user

    def initialize(user)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def self.first_step
      STEPS.first
    end

    def self.last_step
      STEPS.last
    end

    def new_blank_project(attrs = {})
      PafsCore::Project.new(attrs)
    end

    def start_new_project(attrs = {})
      # we will need to position a project so that it 'belongs' somewhere
      # and is 'owned' by a user.  I envisage that we would use the
      # current_user passed into the constructor to get this information.
      project = project_service.create_project(attrs)
      Object::const_get("PafsCore::#{self.class.first_step.to_s.camelcase}Step").new project
    end

    def find(ref_number)
      project_service.find_project(ref_number)
    end

    def search(options = {})
      project_service.search(options)
    end

    def find_project_step(id, step)
      raise ActiveRecord::RecordNotFound.new("Unknown step [#{step}]") unless STEPS.include?(step.to_sym)
      # retrieve and wrap project
      self.class.build_project_step(project_service.find_project(id), step, user)
      # TODO: we might want to check that it is valid to go to this step at this
      # time.  e.g. someone manipulates/bookmarks the url and jumps to a 'sub' step
      # that isn't valid based on the current project attributes
    end

    def self.build_project_step(project, step, user)
      # accept a step or a raw project activerecord object
      project = project.project if project.instance_of? PafsCore::BasicStep
      # TODO: check that this user has permission to access this project
      Object::const_get("PafsCore::#{step.to_s.camelcase}Step").new(project, user)
    end

  private
    def project_service
      @project_service ||= ProjectService.new(user)
    end
  end
end
