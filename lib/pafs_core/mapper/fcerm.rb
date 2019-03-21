module PafsCore
  module Mapper
    class Fcerm1
      attr_accessor :project

      def initialize(project:)
        self.project = project
      end

      def name
        project.name
      end

      def type
        project.project_type
      end

      def national_project_number
        project.reference_number
      end

      def pafs_ons_region
        project.region
      end

      def pafs_region_and_coastal_commitee
        project.rfcc
      end

      def pafs_ea_area
        project.ea_area
      end

      def lrma_name
        project.rma_name
      end

      def lrma_type
        project.rma_type
      end

      def coastal_group
        project.coastal_group
      end

      def risk_source
        project.main_risk
      end

      def moderation_code
        project.moderation_code
      end

      def package_reference
        project.package_reference
      end

      def constituency
        project.constituency
      end

      def pafs_county
        project.county
      end

      def earliest_funding_profile_date
        project.earliest_start_date
      end

      def aspirational_gateway_1
        project.start_business_case_date
      end

      def aspirational_gateway_3
        project.award_contract_date
      end

      def aspirational_start_of_construction
        project.start_construction_date
      end

      def aspirational_gateway_4
        project.ready_for_service_date
      end

      def problem_and_proposed_solution
        project.approach
      end

      def flooding_standard_of_protection_before
        project.flood_protection_before
      end

      def flooding_standard_of_protection_after
        project.flood_protection_after
      end

      def coastal_erosion_standard_of_protection_before
        project.coastal_protection_before
      end

      def coastal_erosion_standard_of_protection_after
        project.coastal_protection_after
      end

      def strategic_approach
        project.strategic_approach
      end

      def duration_of_benefits
        project.duration_of_benefits
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

      def attributes
        {
          name: name,
          type: type,
          national_project_number: national_project_number,
          pafs_ons_region: pafs_ons_region,
          pafs_region_and_coastal_commitee: pafs_region_and_coastal_commitee,
          pafs_ea_area: pafs_ea_area,
          lrma_name: lrma_name,
          lrma_type: lrma_type,
          coastal_group: coastal_group,
          risk_source: risk_source,
          moderation_code: moderation_code,
          constituency: constituency,
          pafs_county: pafs_county,
          earliest_funding_profile_date: earliest_funding_profile_date,
          aspirational_gateway_1: aspirational_gateway_1,
          aspirational_gateway_3: aspirational_gateway_3,
          aspirational_start_of_construction: aspirational_start_of_construction,
          aspirational_gateway_4: aspirational_gateway_4,
          problem_and_proposed_solution: problem_and_proposed_solution,
          flooding_standard_of_protection_before: flooding_standard_of_protection_before,
          floodiung_standard_of_protection_after: flooding_standard_of_protection_after,
          coastal_erosion_standard_of_protection_before: coastal_erosion_standard_of_protection_before,
          coastal_erosion_standard_of_protection_after: coastal_erosion_standard_of_protection_after,
          strategic_approach: strategic_approach,
          duration_of_benefits: duration_of_benefits
        }
      end
    end
  end
end
