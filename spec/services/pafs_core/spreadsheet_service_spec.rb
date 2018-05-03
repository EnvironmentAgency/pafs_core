# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
require 'roo'

A2Z = ("A".."Z").to_a.freeze

def column_index(column_code)
  if column_code.length == 1
    A2Z.index(column_code)
  else
    n = A2Z.index(column_code[0])
    m = A2Z.index(column_code[1])
    26 + (n * 26) + m
  end
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
    let(:test_project_2) { PafsCore::Project.find_by(name: 'Test Project 2') }
    let(:test_project_3) { PafsCore::Project.find_by(name: 'Test Project 3') }
    let(:test_project_4) { PafsCore::Project.find_by(name: 'Test Project 4') }
    let(:test_project_5) { PafsCore::Project.find_by(name: 'Test Project 5') }

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
      pso_area.area_projects.create(project: test_project_2, owner: true)
      rma_area.area_projects.create(project: test_project_5, owner: true)
      pso_area.area_projects.create(project: test_project_3, owner: true)
      rma_area.area_projects.create(project: test_project_4, owner: true)
    end

    let(:first_row) { expected.worksheets[0][6] }
    let(:second_row) { expected.worksheets[0][7] }
    let(:third_row) { expected.worksheets[0][8] }
    let(:fourth_row) { expected.worksheets[0][9] }
    let(:fifth_row) { expected.worksheets[0][10] }

    it 'has a national project number' do
      expect(first_row[column_index('A')].value).to eql(test_project_1.reference_number)
      expect(second_row[column_index('A')].value).to eql(test_project_2.reference_number)
      expect(third_row[column_index('A')].value).to eql(test_project_5.reference_number)
      expect(fourth_row[column_index('A')].value).to eql(test_project_3.reference_number)
      expect(fifth_row[column_index('A')].value).to eql(test_project_4.reference_number)
    end

    it 'has a project name' do
      expect(first_row[column_index('B')].value).to eql(test_project_1.name)
      expect(second_row[column_index('B')].value).to eql(test_project_2.name)
      expect(third_row[column_index('B')].value).to eql(test_project_5.name)
      expect(fourth_row[column_index('B')].value).to eql(test_project_3.name)
      expect(fifth_row[column_index('B')].value).to eql(test_project_4.name)
    end

    it 'has a office of national statistics region'
    it 'has a regional flood and coastal committee'
    it 'has a environment agency area'
    it 'has a lead risk management authority - name'
    it 'has a lead risk management authority - type'
    it 'has a risk source'
    it 'has a moderation code'
    it 'has a package reference'
    it 'has a in consented programme'
    it 'has a national grid reference'
    it 'has a country'
    it 'has a parliamentary constituency - project location'
    it 'has a brief description of problem and proposed solution'
    it 'has a public sector contributors'
    it 'has a private sector contributors'
    it 'has a contributions from other Environment Agency sources'
    it 'has a earliest date funding profile could be accelerated to (first year of TPE spend)'
    it 'has a Gateway 1'
    it 'has a Gateway 3'
    it 'has a Start of construction'
    it 'has a Gateway 4'
    it 'has a Total Project Enxpenditure - PROJECT TOTAL'
    it 'has a GIA - PREVIOUS YEAR'
    it 'has a GIA - 2015/16'
    it 'has a GIA - 2016/17'
    it 'has a GIA - 2018/19'
    it 'has a GIA - 2019/20'
    it 'has a GIA - 2020/21'
    it 'has a GIA - 2021/22'
    it 'has a GIA - 2022/23'
    it 'has a GIA - 2023/24'
    it 'has a GIA - 2024/25'
    it 'has a GIA - 2025/26'
    it 'has a GIA - 2026/27'
    it 'has a GIA - 2027/28 on'
    it 'has a Growth - PREVIOUS YEAR'
    it 'has a Growth - 2015/16'
    it 'has a Growth - 2016/17'
    it 'has a Growth - 2018/19'
    it 'has a Growth - 2019/20'
    it 'has a Growth - 2020/21'
    it 'has a Growth - 2021/22'
    it 'has a Growth - 2022/23'
    it 'has a Growth - 2023/24'
    it 'has a Growth - 2024/25'
    it 'has a Growth - 2025/26'
    it 'has a Growth - 2026/27'
    it 'has a Growth - 2027/28 on'
    it 'has a Local Levy - PREVIOUS YEAR'
    it 'has a Local Levy - 2015/16'
    it 'has a Local Levy - 2016/17'
    it 'has a Local Levy - 2018/19'
    it 'has a Local Levy - 2019/20'
    it 'has a Local Levy - 2020/21'
    it 'has a Local Levy - 2021/22'
    it 'has a Local Levy - 2022/23'
    it 'has a Local Levy - 2023/24'
    it 'has a Local Levy - 2024/25'
    it 'has a Local Levy - 2025/26'
    it 'has a Local Levy - 2026/27'
    it 'has a Local Levy - 2027/28 on'
    it 'has a IDB - PREVIOUS YEAR'
    it 'has a IDB - 2015/16'
    it 'has a IDB - 2016/17'
    it 'has a IDB - 2018/19'
    it 'has a IDB - 2019/20'
    it 'has a IDB - 2020/21'
    it 'has a IDB - 2021/22'
    it 'has a IDB - 2022/23'
    it 'has a IDB - 2023/24'
    it 'has a IDB - 2024/25'
    it 'has a IDB - 2025/26'
    it 'has a IDB - 2026/27'
    it 'has a IDB - 2027/28 on'
    it 'has a Public - PREVIOUS YEAR'
    it 'has a Public - 2015/16'
    it 'has a Public - 2016/17'
    it 'has a Public - 2018/19'
    it 'has a Public - 2019/20'
    it 'has a Public - 2020/21'
    it 'has a Public - 2021/22'
    it 'has a Public - 2022/23'
    it 'has a Public - 2023/24'
    it 'has a Public - 2024/25'
    it 'has a Public - 2025/26'
    it 'has a Public - 2026/27'
    it 'has a Public - 2027/28 on'
    it 'has a Private - PREVIOUS YEAR'
    it 'has a Private - 2015/16'
    it 'has a Private - 2016/17'
    it 'has a Private - 2018/19'
    it 'has a Private - 2019/20'
    it 'has a Private - 2020/21'
    it 'has a Private - 2021/22'
    it 'has a Private - 2022/23'
    it 'has a Private - 2023/24'
    it 'has a Private - 2024/25'
    it 'has a Private - 2025/26'
    it 'has a Private - 2026/27'
    it 'has a Private - 2027/28 on'
    it 'has a Other EA - PREVIOUS YEAR'
    it 'has a Other EA - 2015/16'
    it 'has a Other EA - 2016/17'
    it 'has a Other EA - 2018/19'
    it 'has a Other EA - 2019/20'
    it 'has a Other EA - 2020/21'
    it 'has a Other EA - 2021/22'
    it 'has a Other EA - 2022/23'
    it 'has a Other EA - 2023/24'
    it 'has a Other EA - 2024/25'
    it 'has a Other EA - 2025/26'
    it 'has a Other EA - 2026/27'
    it 'has a Other EA - 2027/28 on'
    it 'has a Further required - PREVIOUS YEAR'
    it 'has a Further required - 2015/16'
    it 'has a Further required - 2016/17'
    it 'has a Further required - 2018/19'
    it 'has a Further required - 2019/20'
    it 'has a Further required - 2020/21'
    it 'has a Further required - 2021/22'
    it 'has a Further required - 2022/23'
    it 'has a Further required - 2023/24'
    it 'has a Further required - 2024/25'
    it 'has a Further required - 2025/26'
    it 'has a Further required - 2026/27'
    it 'has a Further required - 2027/28 on'
    it 'has a OM2 - PREVIOUS YEAR'
    it 'has a OM2 - 2015/16'
    it 'has a OM2 - 2016/17'
    it 'has a OM2 - 2018/19'
    it 'has a OM2 - 2019/20'
    it 'has a OM2 - 2020/21'
    it 'has a OM2 - 2021/22'
    it 'has a OM2 - 2022/23'
    it 'has a OM2 - 2023/24'
    it 'has a OM2 - 2024/25'
    it 'has a OM2 - 2025/26'
    it 'has a OM2 - 2026/27'
    it 'has a OM2 - 2027/28 on'
    it 'has a OM2c - PREVIOUS YEAR'
    it 'has a OM2c - 2015/16'
    it 'has a OM2c - 2016/17'
    it 'has a OM2c - 2018/19'
    it 'has a OM2c - 2019/20'
    it 'has a OM2c - 2020/21'
    it 'has a OM2c - 2021/22'
    it 'has a OM2c - 2022/23'
    it 'has a OM2c - 2023/24'
    it 'has a OM2c - 2024/25'
    it 'has a OM2c - 2025/26'
    it 'has a OM2c - 2026/27'
    it 'has a OM2c - 2027/28 on'
    it 'has a OM3 - PREVIOUS YEAR'
    it 'has a OM3 - 2015/16'
    it 'has a OM3 - 2016/17'
    it 'has a OM3 - 2018/19'
    it 'has a OM3 - 2019/20'
    it 'has a OM3 - 2020/21'
    it 'has a OM3 - 2021/22'
    it 'has a OM3 - 2022/23'
    it 'has a OM3 - 2023/24'
    it 'has a OM3 - 2024/25'
    it 'has a OM3 - 2025/26'
    it 'has a OM3 - 2026/27'
    it 'has a OM3 - 2027/28 on'
    it 'has a OM3b - PREVIOUS YEAR'
    it 'has a OM3b - 2015/16'
    it 'has a OM3b - 2016/17'
    it 'has a OM3b - 2018/19'
    it 'has a OM3b - 2019/20'
    it 'has a OM3b - 2020/21'
    it 'has a OM3b - 2021/22'
    it 'has a OM3b - 2022/23'
    it 'has a OM3b - 2023/24'
    it 'has a OM3b - 2024/25'
    it 'has a OM3b - 2025/26'
    it 'has a OM3b - 2026/27'
    it 'has a OM3b - 2027/28 on'
    it 'has a OM3c - PREVIOUS YEAR'
    it 'has a OM3c - 2015/16'
    it 'has a OM3c - 2016/17'
    it 'has a OM3c - 2018/19'
    it 'has a OM3c - 2019/20'
    it 'has a OM3c - 2020/21'
    it 'has a OM3c - 2021/22'
    it 'has a OM3c - 2022/23'
    it 'has a OM3c - 2023/24'
    it 'has a OM3c - 2024/25'
    it 'has a OM3c - 2025/26'
    it 'has a OM3c - 2026/27'
    it 'has a OM3c - 2027/28 on'
    it 'has a OM4a Total'
    it 'has a OM4b Total'
    it 'has a OM4c Total'
    it 'has a Does the project relate to a designated site'
    it 'has a OM4d Kilometers of WFD water body enhanced'
    it 'has a Does project remove a barrier to migration for fish or eels'
    it 'has a OM4e: Kilometers of water body opened up to fish or el passage'
    it 'has a OM4f: Kilometers of river habitat (including SSSI) enhanced'
    it 'has a OM4g: Hectares of habitat (including SSSI) enhanced'
    it 'has a OM4h: Hectares of habitat created'
    it 'has a TPE 19/20 - 20/21 Total'
    it 'has a GIA + GROWTH 19/20 - 20/21 total'
    it 'has a Contributions 19/20 - 20/21 total'
    it 'has a OM2+3 19/20 - 20/21 total'
    it 'has a TPE 6 Total'
    it 'has a GIA + GROWTH 6 year total'
    it 'has a Contributions 6 year total'
    it 'has a OM2+3 6 total'
    it 'has a PAFS Status'
  end
end
