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
             :timescale,
             :source_of_funding,
             :funding_details,
             :early_start,
             :location,
             :classification,
             :risks,
             :number_of_households,
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

    # TODO: once devise is set up
    #
    # attr_reader :user
    # def initialize(user)
    #   @user = user
    # end

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

    def search(options = {})
      project_service.search(options)
    end

    def find_project_step(id, step)
      raise ActiveRecord::RecordNotFound.new("Unknown step [#{step}]") unless STEPS.include?(step.to_sym)
      # retrieve and wrap project
      Object::const_get("PafsCore::#{step.to_s.camelcase}Step").new project_service.find_project(id)
    end

  private
    def project_service
      @project_service ||= ProjectService.new # user
    end

  end
end
