# frozen_string_literal: true

module PafsCore
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :content_tag, :tag, :safe_join, to: :@template

    def error_header(heading = nil, description = nil, sort_order = nil)
      if @object.errors.any?
        h = heading || I18n.t(:error_heading)
        d = description || I18n.t(:error_description)

        contents = [error_heading(h)]
        contents << error_description(d) unless d.blank?
        contents << if sort_order.nil?
                      error_list
                    else
                      sorted_error_list(sort_order)
                    end

        content_tag(:div, class: "error-summary", role: "group",
                          aria: { labelledby: "error-summary-heading" },
                          tabindex: "-1") do
          safe_join(contents, "\n")
        end
      end
    end

    def fields_for(record_name, record_object = nil, fields_options = {}, &block)
      super record_name, record_object, fields_options.merge(builder: self.class), &block
    end

    def form_group(name)
      name = name.to_sym
      content = []
      content << content_tag(:div) { yield } if block_given?

      content_tag(:div,
                  class: error_class(name, "form-group"),
                  id: content_id(name)) do
                    safe_join(content, "\n")
                  end
    end

    def check_box(attribute, options = {})
      attribute = attribute.to_sym
      label_opts = { class: error_class(attribute, "block-label") }

      label_opts[:data] = { target: content_id(attribute) } if block_given?
      label_value = options[:label] || label_text(attribute)
      f = label(attribute, label_opts) do
        safe_join([super(attribute, options), label_value], "\n")
      end

      if block_given?
        safe_join([f, content_tag(:div,
                                  id: content_id(attribute),
                                  class: "panel js-hidden") do
                                    yield
                                  end])
      else
        f
      end
    end

    def percent_field(attribute, options = {})
      def_opts = {
        class: "form-control form-narrow",
        after: "%",
        in: 0..100,
        maxlength: 3,
        size: 3,
        label_class: "form-label-bold"
      }
      options = options.reverse_merge(def_opts)
      number_field(attribute, options)
    end

    def month_and_year(attribute, options = {})
      m_key = "#{attribute}_month".to_sym
      y_key = "#{attribute}_year".to_sym

      contents = []
      contents << heading_text(options.delete(:heading)) if options.include? :heading
      contents << hint_text(options.delete(:hint)) if options.include? :hint
      contents << error_message(attribute) if @object.errors.include? attribute
      # need to handle the 2 fields as one for errors
      contents << content_tag(:div, class: "form-date") do
        safe_join([
                    content_tag(:div, class: "form-group form-group-month") do
                      safe_join([
                                  label(m_key, I18n.t("month_label"), class: "form-label"),
                                  number_field_without_label(m_key, in: 1..12, maxlength: 2,
                                                                    class: "form-control form-month")
                                ], "\n")
                    end,
                    content_tag(:div, class: "form-group form-group-year") do
                      safe_join([
                                  label(y_key, I18n.t("year_label"), class: "form-label"),
                                  number_field_without_label(y_key,
                                                             in: 2000..2100, maxlength: 4,
                                                             class: "form-control form-year")
                                ], "\n")
                    end
                  ], "\n")
      end

      form_group(attribute) do
        safe_join(contents, "\n")
      end
    end

    def radio_button_group(attribute, items)
      content = []
      content << error_message(attribute) if @object.errors.include? attribute

      items.each do |item|
        content << radio_button(attribute, item.fetch(:value), item.fetch(:options, {}))
      end
      form_group(attribute) do
        safe_join(content, "\n")
      end
    end

    def radio_button(attribute, value, options = {})
      attribute = attribute.to_sym
      label_opts = { class: options.fetch(:label_class, "block-label"), value: value }
      label_opts[:data] = { target: options.fetch(:target) } if options.include?(:target)
      # label_opts[:data] = { target: content_id("#{attribute}-#{value}") } if block_given?

      f = label(attribute, label_opts) do
        safe_join([super(attribute, value, options.except(:label)), label_for(attribute, options)],
                  "\n")
      end

      f
    end

    def select(attribute, choices = nil, options = {}, html_options = {}, &block)
      attribute = attribute.to_sym
      contents = []
      label_val = options.delete(:label) if options.include? :label
      unless label_val == :none
        label_args = [attribute]
        label_args << label_val
        label_args << { class: options.fetch(:label_class, "form-label-bold") }

        contents << label(*label_args)
      end
      contents << hint_text(options.delete(:hint)) if options.include? :hint
      contents << error_message(attribute)
      contents << super

      group_class = options.fetch(:group_class, "form-block")
      content_tag(:div, class: error_class(attribute, group_class)) do
        safe_join(contents, "\n")
      end
    end

    def text_area(attribute, options = {})
      attribute = attribute.to_sym
      contents = []

      label_val = options.delete(:label) if options.include? :label
      unless label_val == :none
        label_args = [attribute]
        label_args << label_val # options.delete(:label) if options.include? :label
        label_args << { class: "form-label" }

        contents << label(*label_args)
      end
      contents << hint_text(options.delete(:hint)) if options.include? :hint
      contents << error_message(attribute)
      contents << super(attribute, options)

      group_class = options.fetch(:group_class, "form-block")
      content_tag(:div, class: error_class(attribute, group_class)) do
        safe_join(contents, "\n")
      end
    end

    def hint_text(text)
      content_tag(:p, text, class: "form-hint")
    end

    def heading_text(text)
      content_tag(:h4, text, class: "heading-small")
    end

    def error_message(attribute)
      if @object.errors.include? attribute
        content = []
        @object.errors.full_messages_for(attribute).each_with_index do |message, i|
          content << content_tag(:p, error_trim(message).html_safe,
                                 class: "error-message",
                                 id: error_id(attribute, i))
        end
        safe_join(content, "\n")
      end
    end

    %i[
      email_field
      password_field
      number_field
      range_field
      search_field
      telephone_field
      text_field
      url_field
    ].each do |method_name|
      define_method("#{method_name}_with_label") do |attribute, *args|
        options = args.extract_options!
        content_after = options.fetch(:after, nil)
        label_args = [attribute]
        label_args << options.fetch(:label) if options.include?(:label)
        label_args << { class: options.fetch(:label_class, "form-label-bold") }
        content = [label(*label_args)]
        content << hint_text(options.fetch(:hint)) if options.include? :hint
        content << error_message(attribute) if @object.errors.include? attribute
        content << send("#{method_name}_without_label", attribute, options.except(:label, :label_class, :hint, :after))
        content << content_after if content_after
        form_group(attribute) do
          safe_join(content, "\n")
        end
      end
      alias_method_chain(method_name, :label)
    end

    private

    def label_for(attribute, options = {})
      if options.include? :label
        options.delete(:label)
      else
        label_text(attribute)
      end
    end

    def error_class(attribute, default_classes)
      "#{default_classes || ''} #{'no-' unless @object.errors.include?(attribute.to_sym)}error"
    end

    def content_id(attribute)
      "#{attr_name(attribute)}-content"
    end

    def error_id(attribute, index = 0)
      "#{attr_name(attribute)}-error-#{index}"
    end

    def attr_name(attribute)
      "#{@object_name}-#{attribute}"
    end

    def label_text(attribute)
      # delegate to the view to handle i18n as it calcs the right scope
      # If we call I18n.t we would need to provide the scope ourselves
      @template.t(".#{attribute}_label")
    end

    def error_heading(heading)
      content_tag(:h1, heading,
                  class: "heading-medium error-summary-heading",
                  id: "error-summary-heading")
    end

    def error_description(description)
      content_tag(:p, description)
    end

    def sorted_error_list(keys)
      el = []
      keys.each do |k|
        @object.errors.full_messages_for(k).each_with_index do |message, i|
          el << error_item(k, message, i)
        end
      end
      content_tag(:ul, class: "error-summary-list") do
        safe_join(el, "\n")
      end
    end

    def error_list
      el = []
      @object.errors.keys.sort.each do |k|
        @object.errors.full_messages_for(k).each_with_index do |message, i|
          el << error_item(k, message, i)
        end
      end
      content_tag(:ul, class: "error-summary-list") do
        safe_join(el, "\n")
      end
    end

    # This enables us to have custom messages without the attribute name
    # at the beginning.
    # When adding a message in a validator do this:
    # errors.add(:my_attr, "^You must do something")
    # When outputting the errors.full_messages / full_messages_for(:attr)
    # pipe it through here to trim off everything upto and including the '^'
    # or just return the original message if no '^' is present
    def error_trim(message)
      message&.split("^")&.last
    end

    def error_item(attr, message, index)
      content_tag(:li, content_tag(:a, error_trim(message), href: "##{error_id(attr, index)}"))
    end
  end
end
