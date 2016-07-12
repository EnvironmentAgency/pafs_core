# frozen_string_literal: true
require "rails_helper"

module PafsCore
  RSpec.describe ProjectsHelper, type: :helper do
    before(:all) { PafsCore::ReferenceCounter.seed_counters }

    describe "#financial_year_end_for" do
      it "returns the end of the financial year for the supplied date" do
        test_date = Date.new(2022, 12, 25)
        expect(helper.financial_year_end_for(test_date)).to eq Date.new(2023, 3, 31)

        test_date = Date.new(2017, 1, 3)
        expect(helper.financial_year_end_for(test_date)).to eq Date.new(2017, 3, 31)
      end
    end

    describe "#six_year_limit_date" do
      it "returns a string for the end of the six year limit financial year" do
        expect(helper.six_year_limit_date).to eq "31 March 2021"
      end
    end

    describe "#str_year" do
      context "when given a year less than zero" do
        it "returns the string 'previous'" do
          expect(helper.str_year(-1)).to eq "previous"
        end
      end
      it "converts a year into a string" do
        expect(helper.str_year(2016)).to eq "2016"
      end
    end

    describe "#formatted_financial_year" do
      context "when given a year less than zero" do
        it "returns the string 'Previous years'" do
          expect(helper.formatted_financial_year(-1)).to eq "Previous years"
        end
      end
      it "returns the financial year range as a string" do
        expect(helper.formatted_financial_year(2016)).to eq "2016 to 2017"
      end
    end

    # describe "#nav_step_item" do
    #   it "builds the navigation DOM nodes for the given project step" do
    #     project = FactoryGirl.create(:project_name_step)
    #     view.class.send(:define_method, :current_resource) { nil }
    #     expect(helper.nav_step_item(project, :project_name)).to include("selected")
    #   end
    # end

    describe "#step_label" do
      it "returns the I18n value for the given label" do
        PafsCore::ProjectNavigator::STEPS.each do |step|
          expect(helper.step_label(step)).to eq I18n.t("#{step}_step_label")
        end
      end
    end

    # describe "#key_date_field" do
    #   context "when the attr param ends in '_month'" do
    #     it "builds the DOM nodes for a month field"
    #   end
    #
    #   context "when the attr param ends in '_year'" do
    #     it "builds the DOM nodes for a year field"
    #   end
    # end
  end
end
