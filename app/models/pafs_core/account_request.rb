# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class AccountRequest < ActiveRecord::Base
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true
    validates :email, uniqueness: true
    validates :organisation, presence: true
    validates :job_title, presence: true
    validates :telephone_number, presence: true
    before_validation :downcase_email
    before_create :generate_slug

    def to_param
      slug
    end

  private
    def generate_slug
      self.slug = email.parameterize
    end

    def downcase_email
      self.email.downcase! unless email.nil?
    end
  end
end
