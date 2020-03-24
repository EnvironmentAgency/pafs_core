# frozen_string_literal: true

module PafsCore
  class BootstrapService
    attr_reader :user

    def initialize(user)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def new_bootstrap(attrs = {})
      PafsCore::Bootstrap.new(initial_attributes.merge(attrs))
    end

    def create_bootstrap(attrs = {})
      PafsCore::Bootstrap.create(initial_attributes.merge(attrs))
    end

    def find(slug)
      # make it a case-insensitive search
      # TODO: security check! can the user actually access this project?
      PafsCore::Bootstrap.find_by!(slug: slug.to_s)
    end

    private

    def initial_attributes
      {
        creator: user
      }
    end
  end
end
