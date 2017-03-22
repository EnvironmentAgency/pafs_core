# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  # Use to set any custom, non-security related response headers. Intended to be
  # used in Controllers and called using a before_action
  #
  # class ApplicationController < ActionController::Base
  #   include PafsCore::CustomHeaders
  #   before_action :cache_busting
  # end
  #
  # Any security related headers should be specified in
  # `config/initializers/secure_headers.rb`
  module CustomHeaders

    def cache_busting
      # Cache buster, specifically we don't want the client to cache any
      # responses from the service
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate, private"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

  end
end
