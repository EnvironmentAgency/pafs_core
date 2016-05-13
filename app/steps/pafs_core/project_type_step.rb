# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ProjectTypeStep < BasicStep
    delegate :project_type, :project_type=,
             :environmental_type, :environmental_type=,
             to: :project

    validates :project_type, presence: true
    validates :project_type, inclusion: { in: PafsCore::PROJECT_TYPES }
    # validate :project_type_is_present_and_is_valid
    validates :environmental_type, presence: true, if: :environmental_project?
    validates :environmental_type, inclusion: { in: PafsCore::ENVIRONMENTAL_TYPES }, if: :environmental_project?

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :financial_year
        true
      else
        false
      end
    end

    def previous_step
      :project_name
    end

    def step
      @step ||= :project_type
    end

    def environmental_project?
      project_type == "ENV"
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:project_type_step).permit(:project_type, :environmental_type)
    end

    # def project_type_is_present_and_is_valid
    #   if project_type.present?
    #     errors.add(:project_type, "must be a valid type") unless PafsCore::PROJECT_TYPES.include?(project_type.to_s)
    #   else
    #     errors.add(:project_type, "must have a value")
    #   end
    # end
  end
end
