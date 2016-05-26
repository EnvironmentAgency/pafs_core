# frozen_string_literal: true
module PafsCore
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :content_tag, :tag, :safe_join, to: :@template

    def error_header(heading = nil, description = nil)
      if @object.errors.any?
        h = heading || I18n.t(:error_heading)
        d = description || I18n.t(:error_description)

        contents = [error_heading(h),
                    error_description(d),
                    error_list]

        content_tag(:div, class: "error-summary", role: "group",
                    aria: { labelledby: "error-summary-heading" },
                    tabindex: "-1") do
                      safe_join(contents, "\n")
                    end
      end
    end

    def form_group(name, &block)
      name = name.to_sym
      # content = [error_message(name)]
      content = []
      content << content_tag(:div) { yield } if block_given?

      content_tag(:div,
                  class: error_class(name, "form-group"),
                  id: content_id(name)) do
                    safe_join(content, "\n")
                  end
    end

    def check_box(attribute, options = {}, &block)
      attribute = attribute.to_sym
      label_opts = { class: error_class(attribute, "block-label") }

      label_opts[:data] = { target: content_id(attribute) } if block_given?

      f = label(attribute, label_opts) do
        safe_join([super(attribute, options), label_text(attribute)], "\n")
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

    def month_and_year(attribute, options = {})
      m_key = "#{attribute}_month".to_sym
      y_key = "#{attribute}_year".to_sym

      contents = [content_tag(:span, label_for(attribute, options), class: "form-label-bold")]
      contents << hint_text(options.delete(:hint)) if options.include? :hint
      contents << error_message(:base) if @object.errors.include? :base
      contents << content_tag(:div, class: "form-date") do
        safe_join([
          content_tag(:div, class: "form-group form-group-month") do
            safe_join([
              label(m_key, I18n.t("month_label"), class: "form-label"),
              number_field(m_key, in: 1..12, maxlength: 2, class: "form-control form-month")
            ], "\n")
          end,
          content_tag(:div, class: "form-group form-group-year") do
            safe_join([
              label(y_key, I18n.t("year_label"), class: "form-label"),
              number_field(y_key, in: 2000..2099, maxlength: 4, class: "form-control form-year")
            ], "\n")
          end
        ], "\n")
      end

      form_group(:base) do
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
      label_opts = { class: "block-label", value: value }
      content = [super(attribute, value, options), label_for(attribute, options)]

      label(attribute, label_opts) do
        safe_join(content, "\n")
      end
    end

    def text_area(attribute, options = {})
      attribute = attribute.to_sym

      label_args = [attribute]
      label_args << options.delete(:label) if options.include? :label
      label_args << { class: "form-label" }

      contents = [label(*label_args)]

      contents << hint_text(options.delete(:hint)) if options.include? :hint
      contents << error_message(attribute)
      contents << super(attribute, options)

      content_tag(:div, class: error_class(attribute, "form-block")) do
        safe_join(contents, "\n")
      end
    end

    def hint_text(text)
      content_tag(:p, text, class: "form-hint")
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

    def error_list
      el = []
      @object.errors.keys.sort.each do |k|
        @object.errors.full_messages_for(k).each_with_index do |message, i|
          el << content_tag(:li, content_tag(:a, error_trim(message), href: "##{error_id(k, i)}"))
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
      message.split("^").last if message
    end

  end
end
