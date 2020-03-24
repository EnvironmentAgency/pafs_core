# frozen_string_literal: true

module PafsCore
  module EmailHelper
    # Embed an image inline into a html email
    def email_image_tag(image, **options)
      path = "app/assets/images"

      full_path = Rails.root.join(path, image)

      unless File.exist? full_path
        # full_path = "#{Gem.loaded_specs['pafs_core'].full_gem_path}#{path}"
        full_path = PafsCore::Engine.root.join(path, "pafs_core", image)
      end

      attachments[image] = File.read full_path
      image_tag attachments[image].url, **options
    end
  end
end
