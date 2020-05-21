# frozen_string_literal: true

module PafsCore
  module Download
    class Base
      include PafsCore::Files

      def initialize(_opts = nil); end

      def self.perform(*opts)
        new(*opts).tap(&:perform)
      end

      def perform
        raise("Override #perform in subclass")
      end
    end
  end
end
