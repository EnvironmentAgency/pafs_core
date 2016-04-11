# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class BasicStep
    include ActiveModel::Model, ActiveRecord::AttributeAssignment

    attr_reader :project

    delegate  :id,
              :reference_number,
              :to_param,
              :persisted?,
              to: :project

    def initialize(model)
      @project = model
    end

    def save!(*)
      if valid?
        project.save!
      else
        raise ActiveRecord::RecordInvalid.new(project.errors.full_messages)
      end
    end

    # override this in the subclass if you need more functionality
    def completed?
      valid?
    end

    # override this in the subclass if the step could conditionally be disabled
    def disabled?
      false
    end

    # override this in the subclass for multi-step processes
    # This asks whether the supplied step is the one that is represented by
    # the subclass. This is used by the navigator to highlight the current
    # active task in the list
    def is_current_step?(a_step)
      step_name.to_sym == a_step.to_sym
    end

    def step_name
      self.class.name.demodulize.chomp("Step").underscore
    end

    def view_path
      "pafs_core/projects/steps/#{step_name}"
    end
  end
end
