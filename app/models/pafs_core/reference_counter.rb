# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class ReferenceCounter < ApplicationRecord
    def self.next_sequence_for(rfcc_code)
      raise ArgumentError, "Invalid RFCC code" unless RFCC_CODES.include? rfcc_code

      counters = []
      # look up the counters for the rfcc_code
      rc = ReferenceCounter.find_by!(rfcc_code: rfcc_code)
      rc.with_lock do
        if rc.low_counter == 999
          rc.high_counter += 1
          rc.low_counter = 1
        else
          rc.low_counter += 1
        end
        counters << rc.high_counter
        counters << rc.low_counter
        rc.save!
      end

      counters
    end

    def self.seed_counters
      RFCC_CODES.each do |code|
        ReferenceCounter.find_or_create_by(rfcc_code: code)
      end
    end
  end
end
