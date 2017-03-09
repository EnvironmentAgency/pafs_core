# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class ApplicationController < ActionController::Base
    include PafsCore::ApplicationHelper
    include PafsCore::CustomHeaders

    protect_from_forgery with: :exception

    before_action :custom_headers

    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_authenticity_token

    private

    def raise_not_found
      raise ActionController::RoutingError.new("Not Found")
    end

    def custom_headers
      response_headers!(response)
    end

    def handle_invalid_authenticity_token(exception)
      Airbrake.notify(exception) if defined? Airbrake
      Rails.logger.error "ApplicationController authenticity failed " \
                         "(browser cookies may have been disabled): #{exception}"

      render "pafs_core/errors/invalid_authenticity_token", status: :forbidden
    end

  end
end
