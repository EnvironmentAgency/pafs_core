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
            public_contributions: project.public_contributor_names,
            private_contributions: project.private_contributor_names,
            other_ea_contributions: project.other_ea_contributor_names,
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
            public_contributions: values.public_contributions,
            private_contributions: values.private_contributions,
            other_ea_contributions: values.other_ea_contributions,
            growth_funding: values.growth_funding,
            not_yet_identified: values.not_yet_identified
          }
        end
      end
    end
  end
end
