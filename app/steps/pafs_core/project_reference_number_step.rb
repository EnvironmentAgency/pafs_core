# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ProjectReferenceNumberStep < BasicStep
    def update(params)
      # nothing to save as this is an informational step only
      @step = :financial_year
      true
    end

    def previous_step
      :project_name
    end

    def step
      @step ||= :project_reference_number
    end
  end
end
