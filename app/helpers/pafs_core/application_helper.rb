# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  module ApplicationHelper
    # for our form builder
    def pafs_form_for(name, *args, &block)
      options = args.extract_options!

      content_tag(:div,
                  form_for(name,
                           *(args << options.merge(builder: PafsCore::FormBuilder)),
                           &block),
                  class: "pafs_form")
    end

    def make_page_title(title)
      "#{title} - #{t(:global_proposition_header)} - GOV.UK"
    end

    # we're not including Devise in the engine so the current_user
    # will not be available unless brought in via the application using this
    # engine (might not even be current_user ...)
    def current_resource
      resource = nil
      if Object.const_defined?("Devise")
        Devise.mappings.values.each do |m|
          resource = send("current_#{m.name}") if send("#{m.name}_signed_in?")
        end
      end
      resource
    end
  end
end
