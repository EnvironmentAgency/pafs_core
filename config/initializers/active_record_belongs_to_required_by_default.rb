# frozen_string_literal: true

# Rails 5 has changed the belongs_to relation to require presence by default.
# This configures the new behaviour in the app explicitly.

Rails.application.config.active_record.belongs_to_required_by_default = true
