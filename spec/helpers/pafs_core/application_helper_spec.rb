# frozen_string_literal: true

require "rails_helper"

module PafsCore
  RSpec.describe PafsCore::ApplicationHelper, type: :helper do
    let(:project) { FactoryBot.build(:project) }

    describe "#pafs_form_for" do
      it "invokes form_for" do
        expect(helper).to receive(:form_for)
        helper.pafs_form_for(project, url: pafs_core.projects_path) {}
      end

      it "wraps the form in a div with the class 'pafs_form'" do
        result = helper.pafs_form_for(project, url: pafs_core.projects_path) {}
        expect(result).to include "<div class=\"pafs_form\"><form"
        expect(result).to include "</form></div>"
      end
    end
  end
end
