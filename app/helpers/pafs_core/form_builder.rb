# frozen_string_literal: true
module PafsCore
  class FormBuilder < ActionView::Helpers::FormBuilder

    def error_header(heading, description = nil)
      if @object.errors.any?
        @template.content_tag(:div,
                              class: "error-summary",
                              role: "group",
                              aria: { labelledby: "error-summary-heading" },
                              tabindex: "-1") do
          @template.concat error_heading(heading)
          @template.concat(error_description(description)) if description.present?
          @template.concat error_list
        end
      end
    end

    def error_heading(heading)
      @template.content_tag(:h1, heading,
                            class: "heading-medium error-summary-heading",
                            id: "error-summary-heading")
    end

    def error_description(description)
      @template.content_tag(:p, description)
    end

    def error_list
      @template.content_tag(:ul, class: "error-summary-list") do
        @object.errors.keys.sort.each do |k|
          @object.errors.full_messages_for(k).each do |message|
            @template.concat(@template.content_tag(:li,
              @template.content_tag(:a, message, href: "##{error_id(k)}")))
          end
        end
      end
    end

    def error_message(attribute)
      if @object.errors.include? attribute
        @object.errors.full_messages_for(attribute).each do |message|
          @template.concat(@template.content_tag(:p, message,
                                                 class: "error-message",
                                                 id: error_id(attribute)))
        end
      end
    end

    def form_group(name, &block)
      @template.content_tag(:div, class: error_class(name, "form-group"), id: content_id(name)) do
        error_message(name)
        yield if block_given?
      end
    end

    def error_class(attribute, default_classes)
      "#{default_classes || ''} #{'no-' unless @object.errors.include?(attribute)}error"
    end

    def check_box(attribute, options = {}, &block)
      label_opts = { class: error_class(attribute, "block-label") }

      label_opts[:data] = { target: content_id(attribute) } if block_given?

      f = label attribute, label_opts do
        @template.concat(super(attribute, options))
        @template.concat(label_text(attribute))
      end

      if block_given?
        f.concat(@template.content_tag(:div, id: content_id(attribute), class: "panel js-hidden") do
          yield
        end)
      end
      f
    end

    def text_area(attribute, options = {})
      @template.content_tag(:div, class: error_class(attribute, "form-block")) do
        @template.concat(label(attribute, class: "form-label"))
        if options.fetch(:hint, false)
          @template.concat(hint_text(options.fetch(:hint)))
          options.except!(:hint)
        end
        error_message(attribute)
        @template.concat(super(attribute, options))
      end
    end

    def hint_text(text)
      @template.content_tag(:p, text, class: "form-hint")
    end

    def content_id(attribute)
      "#{attr_name(attribute)}-content"
    end

    def error_id(attribute)
      "#{attr_name(attribute)}-error"
    end

    def attr_name(attribute)
      "#{@object_name}-#{attribute}"
    end

    def label_text(attribute)
      # delegate to the view to handle i18n as it calcs the right scope
      # If we call I18n.t we would need to provide the scope ourselves
      @template.t(".#{attribute}_label")
    end
  end
end
