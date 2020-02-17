# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CalculatorParser do
  let(:project) { FactoryBot.create(:project) }
  let(:file) { File.open(file_path) }

  describe "#parse" do
    let(:perform) { described_class.parse(file, project) }

    context 'with a v8 PFC' do
      let(:file_path) { File.join(Rails.root, '..', 'fixtures', 'calculators', 'v8.xlsx') }

      it 'parses and saves the strategic approach' do
        expect do
          perform
        end.to change{ project.reload.strategic_approach }.to(true)
      end

      it 'parses and saves the raw_partnership_funding_score' do
        expect do
          perform
        end.to change{ project.reload.raw_partnership_funding_score }.to(59.3077682362934)
      end

      it 'parses and saves the adjusted_partnership_funding_score' do
        expect do
          perform
        end.to change{ project.reload.adjusted_partnership_funding_score }.to(61.1982816278954)
      end

      it 'parses and saves the pv_whole_life_costs' do
        expect do
          perform
        end.to change{ project.reload.pv_whole_life_costs }.to(25897.0)
      end

      it 'parses and saves the pv_whole_life_benefits' do
        expect do
          perform
        end.to change{ project.reload.pv_whole_life_benefits }.to(1234)
      end

      it 'parses and saves the duration_of_benefits' do
        expect do
          perform
        end.to change{ project.reload.duration_of_benefits }.to(50)
      end

      it 'parses and saves the hectares_of_net_water_dependent_habitat_created' do
        expect do
          perform
        end.to change{ project.reload.hectares_of_net_water_dependent_habitat_created }.to(1)
      end

      it 'parses and saves the hectares_of_net_water_intertidal_habitat_created' do
        expect do
          perform
        end.to change{ project.reload.hectares_of_net_water_intertidal_habitat_created }.to(1)
      end

      it 'parses and saves the kilometres_of_protected_river_improved' do
        expect do
          perform
        end.to change{ project.reload.kilometres_of_protected_river_improved }.to(1)
      end
    end

    context 'with a v9 PFC' do
      let(:file_path) { File.join(Rails.root, '..', 'fixtures', 'calculators', 'v9.xlsx') }

      it 'parses and saves the strategic approach' do
        expect do
          perform
        end.to change{ project.reload.strategic_approach }.to(true)
      end

      it 'parses and saves the raw_partnership_funding_score' do
        expect do
          perform
        end.to change{ project.reload.raw_partnership_funding_score }.to(5006.61972804084)
      end

      it 'parses and saves the adjusted_partnership_funding_score' do
        expect do
          perform
        end.to change{ project.reload.adjusted_partnership_funding_score }.to(5026.61972804084)
      end

      it 'parses and saves the pv_whole_life_costs' do
        expect do
          perform
        end.to change{ project.reload.pv_whole_life_costs }.to(10.0)
      end

      it 'parses and saves the pv_whole_life_benefits' do
        expect do
          perform
        end.to change{ project.reload.pv_whole_life_benefits }.to(100.0)
      end

      it 'parses and saves the duration_of_benefits' do
        expect do
          perform
        end.to change{ project.reload.duration_of_benefits }.to(6)
      end

      it 'zeroes the hectares_of_net_water_dependent_habitat_created' do
        expect do
          perform
        end.to change{ project.reload.hectares_of_net_water_dependent_habitat_created }.to(0)
      end

      it 'zeroes the hectares_of_net_water_intertidal_habitat_created' do
        expect do
          perform
        end.to change{ project.reload.hectares_of_net_water_intertidal_habitat_created }.to(0)
      end

      it 'zeroes the kilometres_of_protected_river_improved' do
        expect do
          perform
        end.to change{ project.reload.kilometres_of_protected_river_improved }.to(0)
      end
    end

    context 'with an invalid filetype' do

      let(:file_path) { File.join(Rails.root, '..', 'fixtures', 'calculators', 'invalid_filetype.txt') }

      it "should check that the calculator is an xlsx file" do
        expect { perform }.to raise_error("require an xlsx file")
      end
    end
  end
end
