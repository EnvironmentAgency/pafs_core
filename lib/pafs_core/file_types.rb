# frozen_string_literal: true
module PafsCore
  # file extensions permitted for funding calculator upload
  FUNDING_CALCULATOR_FILE_TYPES = %w[ .xlsx ].freeze

  # file extensions permitted for benefit area file upload
  BENEFIT_AREA_FILE_TYPES = %w[ .jpg .png .svg .bmp .zip .rar ].freeze

  module FileTypes
    def valid_funding_calculator_file?(filename)
      PafsCore::FUNDING_CALCULATOR_FILE_TYPES.include? safe_file_ext(filename).downcase
    end

    def valid_benefit_area_file?(filename)
      PafsCore::BENEFIT_AREA_FILE_TYPES.include? safe_file_ext(filename).downcase
    end

    def acceptable_funding_calculator_types
      PafsCore::FUNDING_CALCULATOR_FILE_TYPES.join(",")
    end

    def acceptable_benefit_area_types
      PafsCore::BENEFIT_AREA_FILE_TYPES.join(",")
    end

    def benefit_area_file_types
      PafsCore::BENEFIT_AREA_FILE_TYPES.map { |t| t[1..-1] }.join(", ").reverse.sub(",", "ro ").reverse
    end

    def safe_file_ext(filename)
      File.extname(filename || "")
    end
  end
end
