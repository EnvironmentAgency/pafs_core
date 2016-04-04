# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

module PafsCore
  RSpec.describe ReferenceCounter, type: :model do
    around(:each) do |spec|
      PafsCore::ReferenceCounter.transaction do
        spec.run
      end
    end

    describe ".next_sequence_number" do
      let(:rfcc_code) { PafsCore::RFCC_CODES.first }
      it "returns the next sequence number for the given RFCC code" do
        sequence_nos = described_class.next_sequence_for(rfcc_code)
        expect(sequence_nos[0]).to eq 0
        expect(sequence_nos[1]).to eq 1
        sequence_nos = described_class.next_sequence_for(rfcc_code)
        expect(sequence_nos[0]).to eq 0
        expect(sequence_nos[1]).to eq 2
      end

      it "increments the high counter and resets the lower counter when the lower counter is greater the than 999" do
        rc = described_class.find_by(rfcc_code: rfcc_code)
        expect(rc.high_counter).to eq(0)
        rc.update_attributes(low_counter: 999)

        sequence_nos = described_class.next_sequence_for(rfcc_code)
        expect(sequence_nos[0]).to eq 1
        expect(sequence_nos[1]).to eq 1
      end
    end
  end
end
