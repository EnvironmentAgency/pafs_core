# frozen_string_literal: true

class AddFundingSourcesVisitedToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :funding_sources_visited, :boolean, nullable: false, default: false
  end
end
