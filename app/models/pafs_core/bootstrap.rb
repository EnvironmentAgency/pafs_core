# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class Bootstrap < ApplicationRecord
    validates :slug, presence: true, uniqueness: true
    belongs_to :creator, class_name: "User", optional: true

    before_validation :set_slug, on: :create

    def reference_number
      slug
    end

    def to_param
      slug
    end

    private

    def set_slug
      self.slug = SecureRandom.urlsafe_base64
    end
  end
end
