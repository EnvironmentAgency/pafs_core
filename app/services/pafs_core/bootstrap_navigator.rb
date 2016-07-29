# frozen_string_literal: true
module PafsCore
  class BootstrapNavigator
    attr_reader :user

    def initialize(user)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def first_step
      sequence.first
    end

    def next_step(step, project)
      sequence.next(step, project)
    end

    def last_step
      sequence.last
    end

    def new_bootstrap(attrs = {})
      bootstrap_service.new_bootstrap(attrs)
    end

    def create_bootstrap(attrs = {})
      # we will need to position a project so that it 'belongs' somewhere
      # and is 'owned' by a user.  I envisage that we would use the
      # current_user passed into the constructor to get this information.
      project = bootstrap_service.create_bootstrap(attrs)
      Object::const_get("PafsCore::#{first_step.to_s.camelcase}Step").new project
    end

    def find_project_step(id, step)
      # retrieve and wrap project
      build_project_step(bootstrap_service.find(id), step, user)
    end

    def build_project_step(project, step, user)
      check_step(step)
      # accept a step or a raw project activerecord object
      project = project.project if project.respond_to? :project
      # TODO: check that this user has permission to access this project
      Object::const_get("PafsCore::#{step.to_s.camelcase}Step").new(project, user)
    end

    def bootstrap_to_project(id)
      project = nil
      bp = bootstrap_service.find(id)
      PafsCore::Bootstrap.transaction do
        project = project_service.create_project(bp.attributes.except("id", "slug", "created_at", "updated_at"))
        bp.destroy!
      end
      project
    end

  private
    def sequence
      @sequence ||= define_sequence
    end

    def define_sequence
      Dibble.sequence do |s|
        s.add :project_name
        s.add :project_type
        s.add :financial_year
        s.add :financial_year_alternative, unless: ->(p) { p.step == :financial_year }
        s.add :hey_im_the_last_step
      end
    end

    def check_step(step)
      raise ActiveRecord::RecordNotFound.new("Unknown step [#{step}]") unless sequence.include? step.to_sym
    end

    def bootstrap_service
      @bootstrap_service ||= BootstrapService.new(user)
    end

    def project_service
      @project_service ||= ProjectService.new(user)
    end
  end
end
