# frozen_string_literal: true
module PafsCore
  class FundingCalculatorStep < BasicStep

    delegate :funding_calculator_file_name, :funding_calculator_file_name=,
             :funding_calculator_content_type, :funding_calculator_content_type=,
             :funding_calculator_file_size, :funding_calculator_file_size=,
             :funding_calculator_updated_at, :funding_calculator_updated_at=,
             :storage_path,
             to: :project

    attr_reader :funding_calculator
    attr_accessor :virus_info
    validates :funding_calculator_file_name, presence: true
    validates :virus_info, absence: true

    def update(params)
      uploaded_file = step_params(params).fetch(:funding_calculator, nil)
      if uploaded_file
        begin
          old_file = funding_calculator_file_name
          # virus check and upload to S3
          filename = File.basename(uploaded_file.original_filename)
          dest_file = File.join(storage_path, filename)
          storage.upload(uploaded_file.tempfile.path, dest_file)

          if old_file && old_file != filename
            # aws doesn't raise an error if it cannot find the key when deleting
            storage.delete(File.join(storage_path, old_file))
          end

          self.funding_calculator_file_name = filename
          self.funding_calculator_content_type = uploaded_file.content_type
          self.funding_calculator_file_size = uploaded_file.size
          self.funding_calculator_updated_at = Time.zone.now
          self.virus_info = nil
        rescue PafsCore::VirusFoundError => e
          Rails.logger.error e.message
          # TODO: we could make a better message here or in the exeception
          self.virus_info = e.message
        rescue PafsCore::VirusScannerError => e
          Rails.logger.error e.message
          # TODO: we could make a better message here or in the exeception
          self.virus_info = e.message
        end
      end

      if valid? && project.save
        @step = :summary
        true
      else
        false
      end
    end

    def previous_step
      :urgency_details
    end

    def step
      @step ||= :funding_calculator
    end

    def download
      if funding_calculator_file_name.present?
        t = Tempfile.new
        storage.download(File.join(storage_path, funding_calculator_file_name), t.path)
        t.rewind

        if block_given?
          yield t.read, funding_calculator_file_name, funding_calculator_content_type
          t.close!
        else
          t
        end
      end
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:funding_calculator_step).
        permit(:funding_calculator)
    end

    def storage
      @storage ||= PafsCore::FileStorageService.new user
    end
  end
end
