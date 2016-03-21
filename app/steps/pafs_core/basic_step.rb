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

    def completed?
      valid?
    end

    def step_name
      self.class.name.demodulize.chomp("Step").underscore
    end

    def view_path
      "pafs_core/projects/steps/#{step_name}"
    end
  end
end
