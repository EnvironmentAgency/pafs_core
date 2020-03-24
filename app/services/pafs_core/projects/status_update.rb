# frozen_string_literal: true

module PafsCore
  module Projects
    class StatusUpdate
      attr_reader :project, :status

      STATUS_MAP = {
        'Draft': :draft,
        'Review': :completed,
        'Submitted': :submitted,
        'Archived': :archived
      }.freeze

      def initialize(project, status)
        @project = project
        @status = status&.to_sym
      end

      def coerced_status
        return status if STATUS_MAP.values.include?(status)

        STATUS_MAP[status] || :draft
      end

      def state
        project.state || project.create_state
      end

      def perform
        state.update_attribute(:state, coerced_status)
      end
    end
  end
end
