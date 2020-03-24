# frozen_string_literal: true

require "memory_profiler"
require "rails_helper"

RSpec.describe PafsCore::DataMigration::GenerateFundingContributorFcerm do
  let(:user) { create(:user, :pso) }

  before do
    100.times do
      create(:full_project, :with_funding_values, public_contribution_names: %w[Matt Test])
    end
  end

  describe "#perform" do
    xit "testing perf" do
      report = MemoryProfiler.report do
        described_class.perform(user)
        puts "complete"
      end

      report.pretty_print
    end
  end
end
