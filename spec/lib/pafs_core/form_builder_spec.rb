# frozen_string_literal: true
require "rails_helper"

class TestHelper < ActionView::Base; end

RSpec.describe PafsCore::FormBuilder, type: :feature do
  let(:helper) { TestHelper.new }
  let(:project) { FactoryBot.build :project_name_step, name: nil }
  let(:builder) { described_class.new project.step, project, helper, {} }

  describe "#error_header" do
    context "when the project has errors" do
      before(:each) do
        project.valid?
        @output = builder.error_header("Errors", "Some errors here")
      end

      context "when no text is supplied as params" do
        before(:each) do
          @output = builder.error_header
        end

        it "heading text defaults to :error_heading i18n locale string" do
          expect(@output).to have_css("h1", text: I18n.t("error_heading"))
        end

        it "description text defaults to :error_description i18n locale string" do
          expect(@output).to have_css("p", text: I18n.t("error_description"))
        end
      end

      it "outputs a header div" do
        expect(@output).to have_css("div.error-summary")
      end

      it "outputs a h1 with the error heading text" do
        expect(@output).to have_css("h1", text: "Errors")
      end

      it "outputs a paragraph containing the description" do
        expect(@output).to have_css("p", text: "Some errors here")
      end

      it "displays a link for each error" do
        project.errors.keys.each do |k|
          project.errors.full_messages_for(k).each_with_index do |msg, i|
            msg = msg.split("^")[1] if msg =~ /\^/
            expect(@output).to have_css("li a[href='##{project.step}-#{k}-error-#{i}']",
                                        text: msg)
          end
        end
      end
    end

    context "when the project has no errors" do
      before(:each) do
        project.name = "My project"
        project.valid?
        @output = builder.error_header("Errors", "Some errors here")
      end

      it "does not output any content" do
        expect(@output).to be nil
      end
    end
  end

  describe "#form_group" do
    context "when the project has no errors" do
      before(:each) do
        project.name = "My project"
        project.valid?
      end

      it "outputs a div with the classes 'form-group' and 'no-error'" do
        output = builder.form_group("wigwam")
        expect(output).to have_css("div.form-group.no-error")
      end
    end

    context "when the project has errors" do
      before(:each) { project.valid? }

      it "outputs a div with the classes 'form-group' and 'error'" do
        output = builder.form_group(:name)
        expect(output).to have_css("div.form-group.error")
      end
    end

    it "uses the name param to generate an id attribute" do
      output = builder.form_group("wigwam")
      expect(output).to have_css("div##{project.step}-wigwam-content")
    end

    it "yields to a block for the div content" do
      output = builder.form_group("wigwam") { "<p>Div content</p>".html_safe }
      expect(output).to have_css("div.form-group p", text: "Div content")
    end
  end

  describe "#check_box" do
    let(:project) { FactoryBot.build :funding_sources_step }

    before(:each) do
      allow(helper).to receive(:t) { "my label" }
      project.valid?
    end

    context "when the attribute has errors" do
      # NOTE: this context is a bit bogus because we don't hang errors
      # from individual checkboxes in the app (yet anyway).
      before(:each) do
        project.fcerm_gia = nil
        project.public_contributions = nil
        project.valid?
        project.errors.add(:fcerm_gia, "is borked")
      end

      it "isn't valid" do
        expect(project.valid?).to be false
      end

      it "adds 'error' to the class attribute of the label" do
        output = builder.check_box(:fcerm_gia)
        expect(output).to have_css("label.block-label.error")
      end
    end

    it "outputs a checkbox control" do
      output = builder.check_box(:fcerm_gia)
      expect(output).to have_css("label.block-label input#funding_sources_fcerm_gia[type='checkbox']")
    end

    it "is valid" do
      expect(project.valid?).to be true
    end

    it "adds 'no-error' to the class attribute of the label" do
      output = builder.check_box(:fcerm_gia)
      expect(output).to have_css("label.block-label.no-error")
    end

    context "when a block is given" do
      before(:each) do
        @output = builder.check_box(:public_contributions) { "<p>Wigwam</p>".html_safe }
      end

      it "adds the block content after the checkbox" do
        expect(@output).to have_css("label.block-label + div.panel.js-hidden")
      end

      it "wraps the block content in a show/hide div panel" do
        expect(@output).to have_css("div.panel.js-hidden p", text: "Wigwam")
      end
    end
  end

  describe "#radio_button" do
    let(:project) { FactoryBot.build :earliest_start_step }

    before(:each) do
      allow(helper).to receive(:t) { "my label" }
      project.valid?
      @output = builder.radio_button(:could_start_early, "true")
    end

    context "when the attribute has errors" do
      # NOTE: this context is a bit bogus because we don't hang errors
      # from an individual radio button in the app (yet anyway).
      before(:each) do
        project.could_start_early = nil
        project.valid?
        @output = builder.radio_button(:could_start_early, "true")
      end

      it "isn't valid" do
        expect(project.valid?).to be false
      end

      it "doesn't add 'error' to the class attribute of the label" do
        expect(@output).not_to have_css("label.block-label.error")
      end
    end

    it "outputs a label for the control using an I18n lookup for the text" do
      expect(@output).to have_css("label.block-label", text: "my label")
    end

    context "when options contain a :label key" do
      it "uses the :label value for the label text" do
        @output = builder.radio_button(:could_start_early, "true", label: "Wigwam")
        expect(@output).to have_css("label.block-label", text: "Wigwam")
      end
    end

    it "outputs a radio button control" do
      expect(@output).to have_css("input#earliest_start_could_start_early_true[type='radio']")
    end

    it "is valid" do
      expect(project.valid?).to be true
    end

    it "doesn't add 'no-error' to the class attribute of the label" do
      expect(@output).not_to have_css("label.block-label.no-error")
    end
  end

  describe "#radio_button_group" do
    let(:project) { FactoryBot.build :earliest_start_step }

    before(:each) do
      allow(helper).to receive(:t) { "my label" }
      project.valid?
      @items = [
        { value: "true", options: { label: "Yes" } },
        { value: "false", options: { label: "No" } }
      ]
      @output = builder.radio_button_group(:could_start_early, @items)
    end

    context "when the attribute has errors" do
      # NOTE: this context is a bit bogus because we don't hang errors
      # from an individual radio button in the app (yet anyway).
      before(:each) do
        project.could_start_early = nil
        project.valid?
        @output = builder.radio_button_group(:could_start_early, @items)
      end

      it "isn't valid" do
        expect(project.valid?).to be false
      end

      it "adds 'error' to the class attribute of the containing div form-group" do
        expect(@output).to have_css("div.form-group.error")
      end
    end

    it "outputs a div form-group container for the radio buttons" do
      expect(@output).to have_css("div.form-group")
    end

    context "when options do not contain a :label key" do
      before(:each) do
        @items = [{ value: "true" }, { value: "false" }]
        @output = builder.radio_button_group(:could_start_early, @items)
      end
      it "uses an I18n lookup for the label text" do
        @items.each do |item|
          expect(@output).
            to have_css("label[for=earliest_start_could_start_early_#{item.fetch(:value)}]", text: "my label")
        end
      end
    end

    it "outputs a radio button control for each value in the group" do
      @items.each do |item|
        expect(@output).to have_css("input#earliest_start_could_start_early_#{item.fetch(:value)}[type='radio']")
      end
    end

    it "is valid" do
      expect(project.valid?).to be true
    end

    it "adds 'no-error' to the class attribute of the containing div form-group" do
      expect(@output).to have_css("div.form-group.no-error")
    end
  end

  describe "#percent_field" do
    let(:project) { FactoryBot.build :standard_of_protection_step }

    before(:each) do
      project.valid?
      allow(helper).to receive(:t) { "my label" }
      @output = builder.percent_field(:flood_protection_before, {})
    end

    it "groups the output with a div" do
      expect(@output).to have_css("div.form-group")
    end

    it "adds 'no-error' to the form group div" do
      expect(@output).to have_css("div.form-group.no-error")
    end

    it "outputs a label for the control" do
      expect(@output).to have_css("label[for='standard_of_protection_flood_protection_before']")
    end

    it "outputs a number field" do
      expect(@output).to have_css("input#standard_of_protection_flood_protection_before[type='number']")
    end
  end

  describe "#month_and_year" do
    let(:project) { FactoryBot.build :earliest_date_step }

    before(:each) do
      project.valid?
      allow(helper).to receive(:t) { "my label" }
      @output = builder.month_and_year(:earliest_start, {})
    end

    it "outputs a div that wraps the content as the attribute supplied" do
      expect(@output).to have_css("div#earliest_date-earliest_start-content.form-group")
    end

    it "adds 'no-error' to the form group div" do
      expect(@output).to have_css("div.form-group.no-error")
    end

    it "outputs a div with the class 'form-date'" do
      expect(@output).to have_css("div.form-group div.form-date")
    end

    context "when :heading is specified in the options" do
      before(:each) do
        @output = builder.month_and_year(:earliest_start, { heading: "Wigwam" })
      end

      it "outputs a h4 element with the text from the options" do
        expect(@output).to have_css("h4.heading-small", text: "Wigwam")
      end
    end

    context "when attribute has errors" do
      before(:each) do
        project.earliest_start_month = nil
        project.earliest_start_year = nil
        project.valid?
        @output = builder.month_and_year(:earliest_start, {})
      end

      it "adds 'error' class to the 'form-group' div" do
        expect(@output).to have_css("div.form-group.error#earliest_date-earliest_start-content")
      end

      it "adds error messages before the input fields" do
        expect(@output).to have_css("p.error-message + div.form-date")
      end
    end

    context "generated input fields" do
      it "outputs a month field with a type of 'number'" do
        expect(@output).to have_css("input#earliest_date_earliest_start_month[type='number']", count: 1)
      end

      it "adds the class 'form-month' to the month field" do
        expect(@output).to have_css("input.form-month")
      end

      it "limits the month field entry to the range 1-12" do
        expect(@output).to have_css("input.form-month[min='1'][max='12']", count: 1)
      end

      it "limits the max month length to 2 characters" do
        expect(@output).to have_css("input.form-month[size='2']", count: 1)
      end

      it "outputs a year field with a type of number" do
        expect(@output).to have_css("input#earliest_date_earliest_start_year[type='number']", count: 1)
      end

      it "adds the class 'form-year' to the year field" do
        expect(@output).to have_css("input.form-year")
      end

      it "limits the year field entry to the range 2000-2100" do
        expect(@output).to have_css("input.form-year[min='2000'][max='2100']", count: 1)
      end

      it "limits the max year length to 4 characters" do
        expect(@output).to have_css("input.form-year[size='4']", count: 1)
      end
    end
  end

  describe "#error_message" do
    let(:project) { FactoryBot.build :project_name_step }
    context "when the attribute has errors" do
      before(:each) do
        project.name = nil
        project.valid?
        @output = builder.error_message(:name)
      end

      it "outputs the error messages" do
        project.errors.full_messages_for(:name).each do |msg|
          msg = msg.split("^")[1] if msg =~ /\^/
          expect(@output).to have_css("p.error-message", text: msg)
        end
      end
    end
  end

  describe "#text_area" do
    let(:project) { FactoryBot.build :public_contributors_step }
    let(:options) { { rows: "2", cols: "40" } }

    before(:each) do
      project.project.public_contributions = true
      project.valid?
      allow(helper).to receive(:t) { "my label" }
      @output = builder.text_area(:public_contributor_names, options)
    end

    context "when the attribute has errors" do
      before(:each) do
        project.public_contributor_names = nil
        project.valid?
        @output = builder.text_area(:public_contributor_names, options)
      end

      it "isn't valid" do
        expect(project.valid?).to be false
      end

      it "adds 'error' to the class attribute of the div" do
        expect(@output).to have_css("div.form-block.error")
      end

      it "outputs the error message" do
        expect(@output).to have_css("div.form-block p.error-message")
      end
    end

    it "outputs a div with the class 'form-block'" do
      expect(@output).to have_css("div.form-block")
    end

    it "outputs a textarea control" do
      expect(@output).to have_css("textarea#public_contributors_public_contributor_names")
    end

    it "outputs a label for the attribute" do
      expect(@output).to have_css("label[for='public_contributors_public_contributor_names']")
    end

    context "when options contain a :label key" do
      let(:label_text) { "My lovely label" }
      it "outputs a label for the attribute using the specified text" do
        @output = builder.text_area(:public_contributor_names, options.merge({ label: label_text }))
        expect(@output).to have_css("label", text: label_text)
      end
    end

    context "when hint text is supplied" do
      let(:hint) { "Always warm the pot" }
      before(:each) do
        @output = builder.text_area(:public_contributor_names, options.merge({ hint: hint }))
      end

      it "outputs the hint text in a paragraph" do
        expect(@output).to have_css("p.form-hint", text: hint)
      end

      it "places the hint text after the label" do
        expect(@output).to have_css("label + p.form-hint")
      end
    end
  end
end
