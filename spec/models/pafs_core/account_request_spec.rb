# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

module PafsCore
  RSpec.describe AccountRequest, type: :model do
    describe "attributes" do
      subject { FactoryBot.create(:account_request) }

      it { is_expected.to validate_presence_of(:first_name).with_message("^Tell us your first name.") }
      it { is_expected.to validate_presence_of(:last_name).with_message("^Tell us your last name.") }
      it { is_expected.to validate_presence_of(:email).with_message("^Tell us your work email address.") }
      it { is_expected.to validate_presence_of(:organisation).with_message("^Tell us the organisation you work for.") }
      it { is_expected.to validate_presence_of(:job_title).with_message("^Tell us your job title.") }
      it { is_expected.to validate_presence_of(:telephone_number).with_message("^Tell us your telephone number.") }

      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    end
  end
end
