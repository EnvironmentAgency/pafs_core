# frozen_string_literal: true
require "rails_helper"

class TestHelper < ActionView::Base; end

RSpec.describe PafsCore::FormBuilder, type: :feature do
  let(:helper) { TestHelper.new }
  let(:project) { FactoryGirl.build :project_name_step, name: nil }
  let(:builder) { described_class.new project.step, project, helper, {} }

  describe "#error_header" do
    context "when the project has errors" do
      before(:each) do
        project.valid?
        @output = builder.error_header("Errors", "Some errors here")
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

      it "outputs the error message before the yielded content" do
        output = builder.form_group(:name) { "<p>Some text</p>".html_safe }
        expect(output).to have_css("div.form-group p:first-child",
                                   text: project.errors.full_messages_for(:name).first)
        expect(output).to have_css("div.form-group p:last-child", text: "Some text")
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
    let(:project) { FactoryGirl.build :funding_sources_step }

    before(:each) do
      allow(helper).to receive(:t) { "my label" }
      project.valid?
    end

    context "when the attribute has errors" do
      # NOTE: this context is a bit bogus because we don't hang errors
      # from checkboxes in the app (yet anyway).
      before(:each) do
        project.fcerm_gia = nil
        project.public_contributions = true
        project.public_contributor_names = nil
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

  describe "#text_area" do
    let(:project) { FactoryGirl.build :funding_sources_step }
    let(:options) { { rows: "2", cols: "40" } }

    before(:each) do
      project.valid?
      allow(helper).to receive(:t) { "my label" }
      @output = builder.text_area(:public_contributor_names, options)
    end

    context "when the attribute has errors" do
      before(:each) do
        project.public_contributions = true
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
        expect(@output).to have_css("div.form-block p.error-message",
                                    text: project.errors.full_messages_for(:public_contributor_names).first)
      end
    end

    it "outputs a div with the class 'form-block'" do
      expect(@output).to have_css("div.form-block")
    end

    it "outputs a textarea control" do
      expect(@output).to have_css("textarea#funding_sources_public_contributor_names")
    end

    it "outputs a label for the attribute" do
      expect(@output).to have_css("label[for='funding_sources_public_contributor_names']")
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
