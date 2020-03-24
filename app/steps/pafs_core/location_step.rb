# frozen_string_literal: true

module PafsCore
  class LocationStep < BasicStep
    delegate :grid_reference, :grid_reference=,
             :region, :region=,
             :county, :county=,
             :parliamentary_constituency, :parliamentary_constituency=,
             :benefit_area_file_name,
             to: :project

    validate :grid_reference_is_supplied

    def update(params)
      @javascript_enabled = !!params.fetch(:js_enabled, false)
      assign_attributes(step_params(params))
      result = false
      if valid?
        # lookup background info
        coords = PafsCore::GridReference.new(grid_reference).to_lat_lon
        data = map_service.fetch_location_data(coords[:latitude], coords[:longitude])
        self.region = data[:region]
        self.county = data[:county]
        self.parliamentary_constituency = data[:parliamentary_constituency]

        result = project.save
      end
      result
    end

    private

    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:location_step)
                                  .permit(:grid_reference)
    end

    def grid_reference_is_supplied
      if grid_reference.present?
        # check format
        gr = PafsCore::GridReference.new grid_reference
        unless gr.valid?
          errors.add(:grid_reference,
                     "^The National Grid Reference must be 2 letters "\
                     "followed by 10 digits")
        end
      else
        errors.add(:grid_reference, "^Tell us the project's National Grid Reference")
      end
    end

    def map_service
      @map_service ||= PafsCore::MapService.new
    end
  end
end
