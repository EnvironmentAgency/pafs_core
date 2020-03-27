# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

# require "cumberland"
require "faraday"

module PafsCore
  class MapService
    def fetch_location_data(latitude, longitude)
      response = connection.get("/postcodes?lat=#{latitude}&lon=#{longitude}&limit=1")
      if response.status == 200
        data = JSON.parse(response.body)
        if data && data["result"]
          data = data["result"].first
          {
            region: data["region"],
            parliamentary_constituency: data["parliamentary_constituency"],
            county: data["admin_county"]
          }
        else
          {
            region: nil,
            parliamentary_constituency: nil,
            county: nil
          }
        end
      else
        raise MapServiceError, "MapService error: #{response.status}"
      end
    rescue Faraday::Error => e
      raise MapServiceError, e
    end

    def connection
      Faraday.new(url: "https://api.postcodes.io") do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end

    #   uri = URI.parse("https://api.postcodes.io/postcodes?lon=#{lng}&lat=#{lat}&wideSearch=1&limit=1")
    # def find(string, project_location)
    #   string = project_location.join(",") if string.blank?
    #   Cumberland.get_location(string, filters)[0..19]
    # end
    #
    # def filters
    #   {
    #     fq: "local_type:city "\
    #     "local_type:town local_type:suburban_area "\
    #     "local_type:village local_type:hamlet"
    #   }
    # end
    #
    # def get_extra_geo_data(coordinates)
    #   eastings = coordinates[0].to_i
    #   northings = coordinates[1].to_i
    #   lat_lng = Cumberland.get_lat_long_from_coordinates(eastings, northings)
    #   postcode_data = call_postcodes_io(lat_lng)
    # end
    #
    # def call_postcodes_io(latlng)
    #   lat = latlng[:lat]
    #   lng = latlng[:long]
    #
    #   uri = URI.parse("https://api.postcodes.io/postcodes?lon=#{lng}&lat=#{lat}&wideSearch=1&limit=1")
    #   result = get_postcodes_io_response(uri)
    #   extract_relevant_data(result)
    # end
    #
    # def get_postcodes_io_response(uri)
    #   http = Net::HTTP.new(uri.host, uri.port)
    #   http.use_ssl = true
    #   request = Net::HTTP::Get.new(uri.request_uri)
    #
    #   response = http.request(request)
    #   body = JSON.parse(response.body)
    #   body["result"].first
    # end
    #
    # def extract_relevant_data(postcode_data)
    #   fields = %w(region parliamentary_constituency)
    #   h = {}
    #
    #   fields.each do |field|
    #     h[field.to_sym] = postcode_data[field]
    #   end
    #
    #   h[:county] = postcode_data["admin_county"]
    #   h
    # end
  end
end
