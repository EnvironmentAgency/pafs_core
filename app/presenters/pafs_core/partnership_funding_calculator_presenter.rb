class PafsCore::PartnershipFundingCalculatorPresenter
  include PafsCore::Files

  attr_accessor :project

  attr_accessor :mapper
  attr_accessor :pv_appraisal_approach

  def initialize(project:)
    fetch_funding_calculator_for(project) do |data, filename, _content_type|
      file = Tempfile.new(filename)
      file.write(data)
      file.close

      self.mapper = PafsCore::Mapper::PartnershipFundingCalculator.new(calculator_file: File.open(file))
    end
  end

  def attributes
    return PafsCore::Mapper::PartnershipFundingCalculator.default_attributes if mapper.nil?

    mapper.attributes
  end
end
