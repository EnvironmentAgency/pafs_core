# frozen_string_literal: true

module PafsCore
  class PagesController < ApplicationController
    helper_method :previous_page

    def cookies; end

    protected

    def previous_page
      request.referer.presence ? request.referer : '/'
    end
  end
end
