# frozen_string_literal: true

module PafsCore
  module Projects
    class ConfidenceUpdate
      attr_reader :project, :value, :attr_name

      VALUE_MAP = {
        'N/A' => :not_applicable,
        '1. Low' => :low,
        '2. Medium Low' => :medium_low,
        '3. Medium High' => :medium_high,
        '4. High' => :high
      }

      def initialize(project, value, attr_name)
        @project = project
        @value = value
        @attr_name = attr_name
      end

      def coerced_value
        return nil if value.blank?

        VALUE_MAP[value]
      end

      def attribute_name
        "confidence_#{attr_name}"
      end

      def perform
        project.update_attribute(attribute_name, coerced_value)
      end
    end
  end
end
