class PafsCore::Camc3Presenter
  def initialize(project:)
    self.project = project

    self.fcerm1_presenter = PafsCore::SpreadsheetPresenter.new(project)
  end

  def attributes
    {
    }
  end

  protected

  attr_accessor :project
  attr_accessor :fcerm1_presenter
end
