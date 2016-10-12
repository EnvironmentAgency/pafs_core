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

    describe "#compound_standard_of_protection_label" do
      it "should return the correct label" do
        option = :very_significant
        label = "<span class=\"bold-small\">Very significant</span><div>5% or greater in any given year</div>"
        expect(helper.compound_standard_of_protection_label(option)).to eq label
      end
    end

    describe "#search_result_label" do
      let(:search_string) { "The search" }
      let(:result) { {eastings: 201212, northings: 121212} }

      it "should return the correct string result" do
        expect(helper.search_result_label(nil, result)).to eq "201212,121212"

        expect(helper.search_result_label(search_string, result)).to eq "The search"
      end
    end

    describe "#file_extension" do
      let(:file_name) { "filename.ext" }

      it "should return the correct file extension in upper case" do
        expect(helper.file_extension(file_name)).to eq "EXT"
      end
    end
  end
end
