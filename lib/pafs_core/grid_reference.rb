# frozen_string_literal: true

require "pafs_core/mapping_transforms"

module PafsCore
  class GridReference
    include MappingTransforms

    def initialize(str)
      @ngr = tidy(str)
    end

    def to_eastings_and_northings
      grid_reference_to_eastings_and_northings(@ngr) if valid?
    end

    def to_lat_lon
      if valid?
        en = grid_reference_to_eastings_and_northings(@ngr)
        easting_northing_to_latitude_longitude(en[:easting], en[:northing])
      end
    end

    def to_s
      @ngr
    end

    def valid?
      @ngr && @ngr =~ /\A[HNST][A-Z](\d{2}|\d{4}|\d{6}|\d{8}|\d{10})\z/ &&
        get_os_grid_ref(@ngr)
    end

    private

    def tidy(str)
      str.to_s.delete("\s").upcase unless str.nil?
    end
  end
end
