# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  # Project type codes
  # DEF - changing the current standard or creating a new asset
  # CM  - reinstating the standard of service of an asset
  # PLP - property level protection
  # BRG - works to bridges that enable FCERM activities but REMOVED by PM-207 26 Jan 2017
  # STR - strategies
  # ENV - environmental projects (not SSSI or BAP)
  PROJECT_TYPES = %w[DEF CM PLP STR ENV_WITH_HOUSEHOLDS ENV_WITHOUT_HOUSEHOLDS].freeze
end
