# frozen_string_literal: true

Rails.application.config.action_dispatch.default_headers.delete(
  'X-Download-Options'
)
