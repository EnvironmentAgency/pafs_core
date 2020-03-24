# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ProgramUploadItem, type: :model do
  describe "attributes" do
    subject { FactoryBot.create(:program_upload_item_success) }

    it { is_expected.to validate_presence_of :reference_number }
  end
end
