# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ProjectService
    attr_reader :user

    def initialize(user = nil)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def new_project
      PafsCore::Project.new(initial_attributes)
    end

    def create_project
      PafsCore::Project.create(initial_attributes)
    end

    def find_project(id)
      # make it a case-insensitive search
      PafsCore::Project.find_by!(slug: id.to_s.upcase)
    end

    def generate_reference_number(rfcc_code = nil)
      rfcc_code = derive_rfcc_code_from_user if rfcc_code.blank?
      sequence_nos = PafsCore::ReferenceCounter.next_sequence_for(rfcc_code)
      "#{rfcc_code}C501E/%03dA/%03dA" % sequence_nos
    end

    def search(options = {})
      #FIXME: just returning all projects while we're scaffolding
      PafsCore::Project.all
    end

    def show_projects(area_id, area_type)
      PafsCore::Project.find_by_sql(%{
        with recursive area_tree(id) as (
          select areas.id from pafs_core_areas areas
          where areas.id = #{area_id}
          union all
          select areas.id from pafs_core_areas areas
          join area_tree
          on areas.parent_id = area_tree.id
        )
        select projects.*, owning_areas.name as owning_area_name
        from pafs_core_projects projects
        join pafs_core_area_projects area_projects
        on area_projects.project_id = projects.id
        join area_tree
        on area_projects.area_id = area_tree.id
        left join pafs_core_area_projects owning_area_projects
        on owning_area_projects.project_id = projects.id
        and owning_area_projects.owner = true
        left join pafs_core_areas owning_areas
        on owning_area_projects.area_id = owning_areas.id
        where area_projects.area_id in (select id from area_tree)
        #{'and area_projects.owner = true' if area_type != PafsCore::Area::AREA_TYPES.last}
      }).uniq
    end

  private
    def initial_attributes
      {
        reference_number: generate_reference_number,
        version: 0,
        # TODO: owner: user
      }
    end

    def derive_rfcc_code_from_user
      #FIXME: this is just until we have the data from the data analyst
      # and we can look this up based on the user's area
      PafsCore::RFCC_CODES.last
    end
  end
end
