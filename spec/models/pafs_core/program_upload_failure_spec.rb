# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProgramUploadFailure, type: :model do
  describe "attributes" do
    subject { FactoryBot.create(:program_upload_failure) }

    it { is_expected.to validate_presence_of :field_name }
    it { is_expected.to validate_presence_of :messages }
  end
end
