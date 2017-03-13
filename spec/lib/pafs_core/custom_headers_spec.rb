# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::CustomHeaders do
  before(:each) do
    @response = OpenStruct.new
    @response.headers = {}
    @response
  end

  describe "#response_headers!" do
    let(:dummy_controller) do
      Class.new { include PafsCore::CustomHeaders }.new
    end

    context "Cache busting" do
      it "sets the necessary headers to prevent caching in the browser" do
        dummy_controller.response_headers!(@response)

        expect(@response.headers["Cache-Control"]).to eq "no-cache, no-store, max-age=0, must-revalidate, private"
        expect(@response.headers["Pragma"]).to eq "no-cache"
        expect(@response.headers["Expires"]).to eq "Fri, 01 Jan 1990 00:00:00 GMT"
      end
    end

    context "Content security policy" do
      it "sets the necessary headers to ensure all content comes from the site's origin" do
        dummy_controller.response_headers!(@response)

        expect(@response.headers["Content-Security-Policy"]).to eq(
          "default-src 'self'; "\
          "script-src 'self' 'unsafe-inline'; "\
          "font-src 'self' data:; "\
          "report-uri https://environmentagency.report-uri.io/r/default/csp/enforce"
        )
      end
    end
  end
end
