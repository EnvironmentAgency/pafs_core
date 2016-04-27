# frozen_string_literal: true
module PafsCore
  class VirusFoundError < StandardError
    attr_reader :file, :virus_name
    def initialize(file_name, virus_name)
      @file = file_name
      @virus_name = virus_name
      super "Found virus [#{virus_name}] in file [#{file_name}]"
    end
  end

  class VirusScannerError < RuntimeError
    def initialize(msg)
      super "Encountered virus scanner problem - [#{msg}]"
    end
  end

  class FileNotFound < RuntimeError
  end
end
