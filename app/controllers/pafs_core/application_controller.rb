# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ApplicationController < ActionController::Base
    include PafsCore::ApplicationHelper
    protect_from_forgery with: :exception

    before_filter :set_cache_headers

  private
    def raise_not_found
      raise ActionController::RoutingError.new("Not Found")
    end

    def set_cache_headers
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate, private"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
  end
end
