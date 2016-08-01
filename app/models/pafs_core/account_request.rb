# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class AccountRequest < ActiveRecord::Base
    validates :first_name, presence: { message: "^Tell us your first name." }
    validates :last_name, presence: { message: "^Tell us your last name." }
    validates :email, presence: { message: "^Tell us your work email address." }
    validates :email, format: {
      with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
      on: :create,
      message: "^Provide a valid work email address."
    }
    validates :email, uniqueness: true
    validates :organisation, presence: { message: "^Tell us the organisation you work for." }
    validates :job_title, presence: { message: "^Tell us your job title." }
    validates :telephone_number, presence: { message: "^Tell us your telephone number." }
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
