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
            public_contributions: serialize_contributors(values.public_contributions),
            private_contributions: serialize_contributors(values.private_contributions),
            other_ea_contributions: serialize_contributors(values.other_ea_contributions),
            growth_funding: values.growth_funding,
            not_yet_identified: values.not_yet_identified
          }
        end
      end

      def serialize_contributors(contributors)
        return nil if contributors.empty?

        contributors.map do |contributor|
          {
            name: contributor.name,
            amount: contributor.amount,
            secured: !!contributor.secured,
            constrained: !!contributor.constrained
          }
        end
      end
    end
  end
end
