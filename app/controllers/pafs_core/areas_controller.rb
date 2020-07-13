# frozen_string_literal: true

module PafsCore
  class AreasController < ApplicationController
    # NOTE: this should be added via a decorator in consuming qpp if needed
    # before_action :authenticate_user!

    def index
      @area = PafsCore::Area.country
      @children = PafsCore::Area.where(parent_id: @area.id)
      render "show"
    end

    def show
      @area = PafsCore::Area.find(params[:id])
      @children = PafsCore::Area.where(parent_id: @area.id)
    end

    def set_user
      @area = PafsCore::Area.find(params[:id])
      if current_resource&.primary_area
        current_resource.user_areas.primary_area.first.update(area_id: @area.id)
        # invalidate the cache for the user so the change of area is forces
        # re-calculation of area visibility
        current_resource.touch
      end
      redirect_to areas_path
    end
  end
end
