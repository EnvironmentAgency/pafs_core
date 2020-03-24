# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CustomHeaders do
  describe "#cache_busting" do
    let(:my_mock) { MockObjectWithResponse.new }

    it "sets the necessary headers to prevent caching in the browser" do
      my_mock.cache_busting

      expect(my_mock.response.headers["Cache-Control"]).to eq "no-cache, no-store, max-age=0, must-revalidate, private"
      expect(my_mock.response.headers["Pragma"]).to eq "no-cache"
      expect(my_mock.response.headers["Expires"]).to eq "Fri, 01 Jan 1990 00:00:00 GMT"
    end
  end
end

# To ensure custom headers is working at its most basic, we include it in a
# PORO that has an attribute called response. This mimics a controller and its
# response attribute
class MockObjectWithResponse
  include PafsCore::CustomHeaders
  attr_reader :response

  def initialize
    @response = OpenStruct.new
    @response.headers = {}
  end
end
