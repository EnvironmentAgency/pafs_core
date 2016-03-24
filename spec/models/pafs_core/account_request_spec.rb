# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

module PafsCore
  RSpec.describe AccountRequest, type: :model do
    describe "attributes" do
      subject { FactoryGirl.create(:account_request) }

      it { is_expected.to validate_presence_of :first_name }
      it { is_expected.to validate_presence_of :last_name }
      it { is_expected.to validate_presence_of :email }
      it { is_expected.to validate_presence_of :organisation }
      it { is_expected.to validate_presence_of :job_title }
      it { is_expected.to validate_presence_of :telephone_number }

      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    end
  end
end
