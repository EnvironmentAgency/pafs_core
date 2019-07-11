module PafsCore
  module Mapper
    class FundingSources
      attr_accessor :project

      def initialize(project:)
        self.project = project
      end

      def attributes
        {
          funding_sources: {
            values: funding_values
          }
        }
      end

      private

      def funding_values
        project.funding_values.order(:financial_year).collect do |values|
          {
            financial_year: values.financial_year,
            fcerm_gia: values.fcerm_gia,
            local_levy: values.local_levy,
            internal_drainage_boards: values.internal_drainage_boards,
            public_contributions: serialize_contributors(
              name: project.public_contributor_names,
              value: values.public_contributions
            ),
            private_contributions: serialize_contributors(
              name: project.private_contributor_names,
              value: values.private_contributions
            ),
            other_ea_contributions: serialize_contributors(
              name: project.other_ea_contributor_names,
              value: values.other_ea_contributions
            ),
            growth_funding: values.growth_funding,
            not_yet_identified: values.not_yet_identified
          }
        end
      end

      def serialize_contributors(name:, value:)
        return nil if name.to_s.strip.blank?

        [
          {
            name: name,
            amount: value.to_i,
            secured: false,
            constrained: false
          }
        ]
      end
    end
  end
end
