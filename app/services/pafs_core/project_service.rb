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

    def create_project(attrs = {})
      p = PafsCore::Project.create!(initial_attributes.merge(attrs))
      p.area_projects.create!(area_id: user.primary_area.id, owner: true)
      p
    end

    def find_project(id)
      # make it a case-insensitive search
      # TODO: security check! can the user actually access this project?
      # PafsCore::Project.find_by!(slug: id.to_s.upcase)
      PafsCore::Project.where(slug: id.to_s.upcase).
        joins(:area_projects).
        merge(PafsCore::AreaProject.where(area_id: area_ids_for_user(user))).
        first!
    end

    def submitted_projects
      PafsCore::Project.joins(:state).
        merge(PafsCore::State.submitted).
        joins(:area_projects).
        merge(PafsCore::AreaProject.where(area_id: area_ids_for_user(user)))
    end

    def find_project_without_security(id)
      PafsCore::Project.find_by!(slug: id.to_s.upcase)
    end

    def self.generate_reference_number(rfcc_code)
      sequence_nos = PafsCore::ReferenceCounter.next_sequence_for(rfcc_code)
      "#{rfcc_code}C501E/%03dA/%03dA" % sequence_nos
    end

    def search(options)
      areas = area_ids_for_user(user)
      sort_col = options[:sort_col];
      sort_order = options[:sort_order]

      sort_col = "updated_at" if sort_col.nil?
      sort_order = "desc" if sort_order.nil?
      results = PafsCore::Project.
                includes(:area_projects, :areas).
                joins(:area_projects).
                merge(PafsCore::AreaProject.where(area_id: areas)).
                order("#{sort_col}": sort_order)
      results = results.joins(:state).
                merge(PafsCore::State.submitted) if user.primary_area.ea_area?

      results
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

    # return an array containing the :ids of all areas the user should see
    # we could potentially cache this list at login or something
    def area_ids_for_user(user)
      Rails.cache.fetch("user/#{user.id}-#{user.updated_at}/areas",
                        expires_in: 1.hour) do
        PafsCore::Area.find_by_sql(%{
          with recursive user_area_tree as (
            ( select a.id from pafs_core_areas a join pafs_core_user_areas ua on
              (a.id = ua.area_id) where ua.user_id = #{user.id}
            )
            union
            (
              select a.id from pafs_core_areas a join user_area_tree uat on (a.parent_id = uat.id)
            )
          )
          select id from user_area_tree
        }).map(&:id).uniq
      end
    end

    def projects_for_user(user)
      PafsCore::Project.find_by_sql(%{
        with recursive user_area_tree as (
          ( select a.id from pafs_core_areas a join pafs_core_user_areas ua on
            (a.id = ua.area_id) where ua.user_id = #{user.id}
          )
          union
          (
            select a.id from pafs_core_areas a join user_area_tree uat on (a.parent_id = uat.id)
          )
        )
        select * from pafs_core_projects p
        join pafs_core_area_projects ap on (ap.project_id = p.id)
        where ap.area_id in
        (
          select uat.id from user_area_tree uat
        )
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
