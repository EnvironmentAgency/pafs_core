# frozen_string_literal: true
module PafsCore
  class ProjectService
    attr_reader :user

    def initialize(user)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def new_project
      PafsCore::Project.new(initial_attributes)
    end

    def create_project
      p = PafsCore::Project.create(initial_attributes)
      p.area_projects.create(area_id: user.primary_area.id, owner: true)
      p
    end

    def find_project(id)
      # make it a case-insensitive search
      PafsCore::Project.find_by!(slug: id.to_s.upcase)
    end

    def self.generate_reference_number(rfcc_code)
      raise ArgumentError.new("Invalid RFCC code: [#{rfcc_code}]") unless PafsCore::RFCC_CODES.include? rfcc_code
      sequence_nos = PafsCore::ReferenceCounter.next_sequence_for(rfcc_code)
      "#{rfcc_code}C501E/%03dA/%03dA" % sequence_nos
    end

    def search(options = {})
      #FIXME: just returning all projects while we're scaffolding
      PafsCore::Project.all
    end

    def all_projects_for(area)
      PafsCore::Project.find_by_sql(%{
        with recursive area_tree(id) as (
          select areas.id from pafs_core_areas areas
          where areas.id = #{area.id}
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
        #{'and area_projects.owner = true' unless area.rma?}
      }).uniq
    end

  private
    def initial_attributes
      {
        reference_number: self.class.generate_reference_number(derive_rfcc_code_from_user),
        version: 1,
        creator: user
      }
    end

    def derive_rfcc_code_from_user
      raise RuntimeError, "User has no RFCC area code" unless user.rfcc_code
      user.rfcc_code
    end
  end
end
