# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "cumberland"

module PafsCore
  class MapService
    def find(string, project_location)
      string = project_location.join(",") if ["", nil].include?(string)
      Cumberland.get_location(string)
    end
  end
end
