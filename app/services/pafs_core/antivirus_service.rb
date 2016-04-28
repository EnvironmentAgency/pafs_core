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

    def service_available?
      scanner.execute(ClamAV::Commands::PingCommand.new)
    end

    def scan(path)
      # default clamav scan op is SCAN which stops when it finds a virus
      # so you would need to quarantine the file and re-scan until no virii
      # were found
      file = path.to_s

      # this is a file in /tmp with 0400 perms by default
      # need to make it accessible to the virus scanner
      File.chmod(0444, file) if File.file? file

      results = scanner.execute(ClamAV::Commands::ScanCommand.new(file))
      results.each do |result|
        if result.instance_of? ClamAV::VirusResponse
          raise PafsCore::VirusFoundError.new(result.file, result.virus_name)
        elsif result.instance_of? ClamAV::ErrorResponse
          raise PafsCore::VirusScannerError.new(result.error_str)
        end
      end
      true
    end

  private
    def scanner
      ClamAV::Client.new
    end
  end
end
