require 'pafs_core/shapefile_serializer'

class PafsCore::Camc3Presenter
  def initialize(project:)
    self.project = project

    self.funding_sources_mapper = PafsCore::Mapper::FundingSources.new(project: project)
    self.fcerm1_presenter = PafsCore::SpreadsheetPresenter.new(project)
    self.fcerm1_mapper = PafsCore::Mapper::Fcerm1.new(project: self.fcerm1_presenter)
    self.pf_calculator_presenter = PafsCore::PartnershipFundingCalculatorPresenter.new(project: project)
  end

  def households_at_reduced_risk
    financial_years.collect do |year|
      {
        year: year,
        value: fcerm1_presenter.households_at_reduced_risk(year)
      }
    end
  end

  def moved_from_very_significant_and_significant_to_moderate_or_low
    financial_years.collect do |year|
      {
        year: year,
        value: fcerm1_presenter.moved_from_very_significant_and_significant_to_moderate_or_low(year)
      }
    end
  end

  def households_protected_from_loss_in_20_percent_most_deprived
    financial_years.collect do |year|
      {
        year: year,
        value: fcerm1_presenter.households_protected_from_loss_in_20_percent_most_deprived(year)
      }
    end
  end

  def coastal_households_at_reduced_risk
    financial_years.collect do |year|
      {
        year: year,
        value: fcerm1_presenter.coastal_households_at_reduced_risk(year)
      }
    end
  end

  def coastal_households_protected_from_loss_in_next_20_years
    financial_years.collect do |year|
      {
        year: year,
        value: fcerm1_presenter.coastal_households_protected_from_loss_in_next_20_years(year)
      }
    end
  end

  def coastal_households_protected_from_loss_in_20_percent_most_deprived
    financial_years.collect do |year|
      {
        year: year,
        value: fcerm1_presenter.coastal_households_protected_from_loss_in_20_percent_most_deprived(year)
      }
    end
  end

  def base64_shapefile
    @base64_shapefile ||= PafsCore::ShapefileSerializer.serialize(project)
  end

  def attributes
    fcerm1_mapper.attributes
      .merge(pf_calculator_presenter.attributes)
      .merge(funding_sources_mapper.attributes)
      .merge(
        {
          confidence: {
            homes_better_protected: project.confidence_homes_better_protected,
            homes_by_gateway_four: project.confidence_homes_by_gateway_four,
            secured_partnership_funding: project.confidence_secured_partnership_funding
          }
        }
      )
      .merge(
        {
          national_grid_reference: project.grid_reference,
          shapefile: base64_shapefile,
          urgency_details: fcerm1_presenter.urgency_details,
          outcome_measures: {
            om2: households_at_reduced_risk,
            om2b: moved_from_very_significant_and_significant_to_moderate_or_low,
            om2c: households_protected_from_loss_in_20_percent_most_deprived,
            om3: coastal_households_at_reduced_risk,
            om3b: coastal_households_protected_from_loss_in_next_20_years,
            om3c: coastal_households_protected_from_loss_in_20_percent_most_deprived,
            om4a: fcerm1_presenter.hectares_of_net_water_dependent_habitat_created,
            om4b: fcerm1_presenter.hectares_of_net_water_intertidal_habitat_created,
            om4c: fcerm1_presenter.kilometres_of_protected_river_improved,
            om4d: fcerm1_presenter.improve_surface_or_groundwater_amount,
            om4e: fcerm1_presenter.fish_or_eel_amount,
            om4f: fcerm1_presenter.improve_river_amount,
            om4g: fcerm1_presenter.improve_habitat_amount,
            om4h: fcerm1_presenter.create_habitat_amount,
          }
        }
    )
  end

  protected

  attr_accessor :project
  attr_accessor :fcerm1_presenter, :pf_calculator_presenter
  attr_accessor :fcerm1_mapper
  attr_accessor :funding_sources_mapper

  def financial_years
    [
      -1,
      2015,
      2016,
      2017,
      2018,
      2019,
      2020,
      2021,
      2022,
      2023,
      2024,
      2025,
      2026,
      2027,
      2028,
    ]
  end
end
