class PafsCore::PartnershipFundingCalculatorPresenter
  include PafsCore::Files

  attr_accessor :project
  attr_accessor :file

  attr_accessor :mapper
  attr_accessor :pv_appraisal_approach

  def initialize(project:, file: nil)
    self.file = file
    fetch_funding_calculator(project)
    self.mapper = PafsCore::Mapper::PartnershipFundingCalculator.new(calculator_file: File.open(self.file))
  end

  def attributes
    mapper.data
  end

  protected
  def fetch_funding_calculator(project)
    fetch_funding_calculator_for(project) do |data, filename, content_type|
      self.file = Tempfile.new(filename)
      self.file.write(data)
      self.file.close
    end
  end
end
