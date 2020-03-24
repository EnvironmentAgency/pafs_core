# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ApplicationController, type: :controller do
  controller do
    def index
      render plain: "Hello World"
    end
  end

  describe "response" do
    it "has cache busting headers in the response" do
      get :index

      expect(response.headers["Cache-Control"]).to eq "no-cache, no-store, max-age=0, must-revalidate, private"
      expect(response.headers["Pragma"]).to eq "no-cache"
      expect(response.headers["Expires"]).to eq "Fri, 01 Jan 1990 00:00:00 GMT"
    end

    # TODO: As core holds the secure_headers gem and its config, it would be
    # nice to confirm that all responses from it include our
    # Content-Security-Policy however currently we can't figure out how to get
    # secure_headers to kick in via a test.
    it "has Content-Security-Policy header in the response" do
      skip "Cannot ascertain how to invoke secure_headers from pafs_core"
      get :index

      expect(response.headers["Content-Security-Policy"]).to eq "boo"
    end
  end
end
