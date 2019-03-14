class PafsCore::PartnershipFundingCalculatorPresenter
  include PafsCore::Files

  attr_accessor :project

  attr_accessor :mapper
  attr_accessor :pv_appraisal_approach

  def initialize(project:)
    fetch_funding_calculator_for(project) do |data, filename, content_type|
      file = Tempfile.new(filename)
      file.write(data)
      file.close

      self.mapper = PafsCore::Mapper::PartnershipFundingCalculator.new(calculator_file: File.open(file))
    end
  end

  def attributes
    mapper.attributes
  end
end
