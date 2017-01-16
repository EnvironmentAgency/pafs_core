# frozen_string_literal: true

module PafsCore
  class AsiteService
    include PafsCore::Files

    attr_reader :user

    def initialize(user = nil)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def submit_project(project)
      # wrap the project to give us access to some helpers
      project = PafsCore::ProjectSummaryPresenter.new(project)

      submission = project.asite_submissions.create(email_sent_at: Time.zone.now)
      attachments = {}

      fcerm1 = generate_fcerm1(project, :xlsx)
      tmp_fcerm1 = Tempfile.new
      fcerm1.serialize(tmp_fcerm1)
      tmp_fcerm1.rewind
      add_attachment(submission,
                     attachments,
                     fcerm1_filename(project.reference_number, :xlsx),
                     tmp_fcerm1.read)
      tmp_fcerm1.close!

      if project.benefit_area_file_name
        fetch_benefit_area_file_for(project) do |data, filename, _content_type|
          add_attachment(submission, attachments, filename, data)
        end
      end

      if project.funding_calculator_file_name
        fetch_funding_calculator_for(project) do |data, filename, _content_type|
          add_attachment(submission, attachments, filename, data)
        end
      end

      if project.urgent?
        generate_moderation_for(project) do |data, filename, _content_type|
          add_attachment(submission, attachments, filename, data)
        end
      end

      # generate attachments and send to asite
      PafsCore::AsiteMailer.submit_project(project.slug, attachments).deliver_now

      submission.submission_state.send!
    end

    def add_attachment(submission, attachments, filename, data)
      submission.asite_files.create(filename: filename,
                                    checksum: checksum(data))
      attachments[filename] = data
    end

    def checksum(data)
      Digest::SHA1.hexdigest(data)
    end
  end
end
