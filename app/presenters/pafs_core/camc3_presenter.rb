class PafsCore::Camc3Presenter
  def initialize(project:)
    self.project = project

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

  def coastal_households_protected_from_loss_in_20_percent_most_deprived
    financial_years.collect do |year|
      {
        year: year,
        value: fcerm1_presenter.coastal_households_protected_from_loss_in_20_percent_most_deprived(year)
      }
    end
  end

  def attributes
    fcerm1_mapper.attributes
      .merge(pf_calculator_presenter.attributes)
      .merge(
        {
          households_at_reduced_risk: households_at_reduced_risk,
          moved_from_very_significant_and_significant_to_moderate_or_low: moved_from_very_significant_and_significant_to_moderate_or_low,
          households_protected_from_loss_in_20_percent_most_deprived: households_protected_from_loss_in_20_percent_most_deprived,
          coastal_households_at_reduced_risk: coastal_households_at_reduced_risk,
          coastal_households_protected_from_loss_in_20_percent_most_deprived: coastal_households_protected_from_loss_in_20_percent_most_deprived
        }
    )
  end

  protected

  attr_accessor :project
  attr_accessor :fcerm1_presenter, :pf_calculator_presenter
  attr_accessor :fcerm1_mapper

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
