# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "clamav/client"
module PafsCore
  class AntivirusService
    attr_reader :user

    def initialize(user = nil)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def scan(file)
      scanner.execute(ClamAV::Commands::ScanCommand.new(file))
    end

  private
    def scanner
      ClamAV::Client.new
    end
  end
end
