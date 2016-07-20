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
        expect(helper.six_year_limit_date).to eq Date.new(2021, 3, 31).to_s(:long_ordinal)
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

    describe "#location_search_results_for" do
      it "should return the correct sentence" do
        query = "Oxford"
        results = ["Oxford"]
        word = "result"
        description = "found for"
        response = "1 result found for <strong class=\"bold-small\">Oxford</strong>"

        expect(helper.location_search_results_for(results, query, word, description)).to eq response

        results.push("Whitney")
        response = "2 results found for <strong class=\"bold-small\">Oxford</strong>"
        expect(helper.location_search_results_for(results, query, word, description)).to eq response
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
