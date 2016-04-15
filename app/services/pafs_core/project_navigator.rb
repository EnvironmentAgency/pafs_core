# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ProjectNavigator

    # add 'pages' or 'steps' to the STEPS list
    # NOTE: STEPS.first and STEPS.last are used to determine the start
    # and end points for the user's journey (although we can change this)
    STEPS = [:project_name,
             :project_reference_number,
             :financial_year,
             :key_dates,
             :funding_sources,
             :funding_details,
             :earliest_start,
             :earliest_date, # not in nav - accessible by choosing 'Yes' on :earliest_start
             :location,
             :map,
             :classification,
             :risks,
             :main_risk, # not in nav - accessible following :risks
             :households_benefiting,
             :standard_of_protection,
             :outcomes,
             :defra,
             :directives,
             :environmental_issues,
             :higher_priority,
             :funding_calculator,
             :summary].freeze

    # Not sure we really need this --v
    # GROUPS = {
    #   project_details: [:project_name,
    #                     :project_details,
    #                     :financial_year,
    #                     :timescale],
    #   funding: [:source_of_funding,
    #             :funding_details,
    #             :early_start],
    #   location_and_type: [:location,
    #                       :classification],
    #   beneficiaries: [:risks,
    #                   :number_of_households,
    #                   :standard_of_protection,
    #                   :outcomes],
    #   related_programs: [:defra,
    #                      :directives],
    #   other: [:environmental_issues,
    #           :higher_priority,
    #           :funding_calculator,
    #           :summary]
    # }

    attr_reader :user

    def initialize(user = nil)
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

    def start_new_project
      # we will need to position a project so that it 'belongs' somewhere
      # and is 'owned' by a user.  I envisage that we would use the
      # current_user passed into the constructor to get this information.
      project = project_service.create_project
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
      self.class.build_project_step(project_service.find_project(id), step)
      # TODO: we might want to check that it is valid to go to this step at this
      # time.  e.g. someone manipulates/bookmarks the url and jumps to a 'sub' step
      # that isn't valid based on the current project attributes
    end

    def self.build_project_step(project, step)
      # accept a step or a raw project activerecord object
      project = project.project if project.instance_of? PafsCore::BasicStep

      Object::const_get("PafsCore::#{step.to_s.camelcase}Step").new(project)
    end

  private
    def project_service
      @project_service ||= ProjectService.new(user)
    end
  end
end
