# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
require 'roo'

A2Z = ("A".."Z").to_a.freeze

class SpreadsheetMapperHelper
  extend PafsCore::Fcerm1
end

RSpec.describe PafsCore::SpreadsheetService do
  subject { PafsCore::SpreadsheetService.new }

  describe "#generate_multi_xlsx" do
    let(:program_upload) { PafsCore::ProgramUploadService.new }
    let(:filename) { 'expected_program_spreadsheet.xlsx' }
    let(:content_type) { "text/plain" }

    let(:file_path) { File.join(Rails.root, "..", "fixtures", filename) }
    let(:file) { File.open(file_path) }
    let(:projects) { PafsCore::Project.all }
    let(:expected) { subject.generate_multi_xlsx(projects) }

    let(:test_project_1) { PafsCore::Project.find_by(name: 'Test Project 1') }

    let(:spreadsheet_presenter_1) { PafsCore::SpreadsheetPresenter.new(test_project_1) }

    let(:uploaded_file) do
      ActionDispatch::Http::UploadedFile.new(tempfile: File.open(file_path),
                                             filename: filename.dup,
                                             type: content_type)
    end

    let(:program_uploads_params) do
      {
        program_upload_file: uploaded_file,
        reset_consented_flag: false
      }
    end

    let(:pso_area) { PafsCore::Area.find_by(name: 'PSO Test Area') }
    let(:rma_area) { PafsCore::Area.find_by(name: 'RMA Test Area') }

    before(:each) do
      file_path = "#{Rails.root}/../fixtures/test_areas.csv"
      PafsCore::AreaImporter.new.import(file_path)

      VCR.use_cassette('process_spreadsheet_with_postcodes') do
        record = program_upload.upload(program_uploads_params)
        program_upload.process_spreadsheet(record)
      end

      pso_area.area_projects.create(project: test_project_1, owner: true)
    end

    let(:first_row) { expected.worksheets[0][6] }
    let(:second_row) { expected.worksheets[0][7] }
    let(:third_row) { expected.worksheets[0][8] }
    let(:fourth_row) { expected.worksheets[0][9] }
    let(:fifth_row) { expected.worksheets[0][10] }

    it 'includes the project reference number' do
      expect(first_row[SpreadsheetMapperHelper.column_index('A')].value).to eql(spreadsheet_presenter_1.reference_number)
    end

    it 'includes column B' do
      expect(first_row[SpreadsheetMapperHelper.column_index('B')].value).to eql(spreadsheet_presenter_1.name)
    end

    it 'includes column JS' do
      expect(first_row[SpreadsheetMapperHelper.column_index('JS')].value).to eql(spreadsheet_presenter_1.designated_site)
    end

    it 'includes JT' do
      expect(first_row[SpreadsheetMapperHelper.column_index('JT')].value).to eql(spreadsheet_presenter_1.improve_surface_or_groundwater_amount)
    end

    it 'includes column JU' do
      expect(first_row[SpreadsheetMapperHelper.column_index('JU')].value).to eql(spreadsheet_presenter_1.remove_fish_or_eel_barrier)
    end

    it 'includes column JV' do
      expect(first_row[SpreadsheetMapperHelper.column_index('JV')].value).to eql(spreadsheet_presenter_1.fish_or_eel_amount)
    end

    it 'includes column JW' do
      expect(first_row[SpreadsheetMapperHelper.column_index('JW')].value).to eql(spreadsheet_presenter_1.improve_river_amount)
    end

    it 'includes column JX' do
      expect(first_row[SpreadsheetMapperHelper.column_index('JX')].value).to eql(spreadsheet_presenter_1.improve_habitat_amount)
    end

    it 'includes column JY' do
      expect(first_row[SpreadsheetMapperHelper.column_index('JY')].value).to eql(spreadsheet_presenter_1.create_habitat_amount)
    end

    it 'includes column KL' do
      expect(first_row[SpreadsheetMapperHelper.column_index('KL')].value.to_s).to eql(spreadsheet_presenter_1.state.state)
    end
  end
end
