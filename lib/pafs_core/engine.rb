# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class Engine < ::Rails::Engine
    isolate_namespace PafsCore

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
      g.assets false
      g.helper false
    end

    initializer "pafs_core.factories", :after => "factory_girl.set_factory_paths" do
      FactoryGirl.definition_file_paths << File.expand_path('../../../spec/factories', __FILE__) if defined?(FactoryGirl)
    end
  end
end
