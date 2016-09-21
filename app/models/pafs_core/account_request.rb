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
      message: "^Enter a valid work email address."
    }, allow_blank: true
    validates :email, uniqueness: true
    validates :organisation, presence: { message: "^Tell us the organisation you work for." }
    validates :job_title, presence: { message: "^Tell us your job title." }
    validates :telephone_number, presence: { message: "^Tell us your telephone number." }
    validates :telephone_number, format: {
      with: /\A(?x)(?:(?:\(?(?:0(?:0|11)\)?[\s-]?\(?|\+)44\)?[\s-]?(?:\(?0\)?[\s-]?)?)|
        (?:\(?0))(?:(?:\d{5}\)?[\s-]?\d{4,5})|(?:\d{4}\)?[\s-]?(?:\d{5}|\d{3}[\s-]?\d{3}))|
        (?:\d{3}\)?[\s-]?\d{3}[\s-]?\d{3,4})|(?:\d{2}\)?[\s-]?\d{4}[\s-]?\d{4}))
        (?:[\s-]?(?:x|ext\.?|\#)\d{3,4})?\z/,
      on: :create,
      message: "^Enter a valid telephone number"
    }, allow_blank: true
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
