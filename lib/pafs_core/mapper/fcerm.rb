module PafsCore
  module Mapper
    class Fcerm1
      attr_accessor :project

      def initialize(project:)
        self.project = project
      end

      def households_at_reduced_risk(year)
        project.households_at_reduced_risk(year)
      end

      def moved_from_very_significant_and_significant_to_moderate_or_low(year)
        project.moved_from_very_significant_and_significant_to_moderate_or_low(year)
      end

      def households_protected_from_loss_in_20_percent_most_deprived(year)
        project.households_protected_from_loss_in_20_percent_most_deprived(year)
      end

      def coastal_households_at_reduced_risk(year)
        project.coastal_households_at_reduced_risk(year)
      end

      def coastal_households_protected_from_loss_in_20_percent_most_deprived(year)
        project.coastal_households_protected_from_loss_in_20_percent_most_deprived(year)
      end
    end
  end
end
