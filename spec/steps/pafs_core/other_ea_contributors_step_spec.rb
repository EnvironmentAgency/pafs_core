# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::OtherEaContributorsStep, type: :model do
  let(:project) { create(:project) }
  subject { described_class.new(project) }

  describe "attributes" do
    it_behaves_like "a project step"
  end
end
