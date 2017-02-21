# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ApplicationController < ActionController::Base
    include PafsCore::ApplicationHelper
    protect_from_forgery with: :exception

    before_filter :set_cache_headers

    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_authenticity_token

  private
    def raise_not_found
      raise ActionController::RoutingError.new("Not Found")
    end

    def set_cache_headers
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate, private"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

    def handle_invalid_authenticity_token(exception)
      Airbrake.notify(exception) if defined? Airbrake
      Rails.logger.error "ApplicationController authenticity failed " \
                         "(browser cookies may have been disabled): #{exception}"

      render "pafs_core/errors/invalid_authenticity_token"
    end
  end
end
