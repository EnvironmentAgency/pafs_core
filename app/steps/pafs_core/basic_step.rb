# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class BasicStep
    include ActiveModel::Model, ActiveRecord::AttributeAssignment

    attr_reader :navigator, :project

    delegate  :id,
              :reference_number,
              :to_param,
              :persisted?,
              to: :project

    def initialize(navigator, model)
      @navigator = navigator
      @project = model
    end

    # override this in the subclass if you need more functionality
    def completed?
      valid?
    end

    # override this in the subclass if the step could conditionally be disabled
    def disabled?
      false
    end

    def step_name
      self.class.name.demodulize.chomp("Step").underscore
    end

    def view_path
      "pafs_core/projects/steps/#{step_name}"
    end
  end
end
