# frozen_string_literal: true

module PafsCore
  class ConfirmationController < ActionController::Base
    include CustomHeaders

    protect_from_forgery with: :null_session
    before_action :cache_busting

    # Callback from Asite to indicate that they have received our email and that
    # the attached files are complete and unaltered
    # The body of the request should contain a JSON payload containing the project
    # reference number and an array with one entry for each file attached to the
    # email, containing the filename and checksum (SHA1 hash of file) e.g.
    #
    # {"confirmation":"THC501E-000A-023A",
    # "attachments":[{"filename":"THC501E-000A-023A_FCERM1.xlsx","checksum":"e3576e89a4f7419cfe292693ba095f866ca4b1d2"},
    # {"filename":"THC501E-000A-023A_benefit_area.jpg","checksum":"01c5cd8752e45db724c769e56f09ac9306bfdbfb"},
    # {"filename":"THC501E-000A-023A_PFcalculator.xlsx","checksum":"82614254822aa9274ceb159bc651e323ed86000d"},
    # {"filename":"THC501E-000A-023A_moderation_BL.txt","checksum":"4f9544b47018de0d2a9330ba1ba29fc947b20461"}]}
    #
    # POST
    def receipt
      # expecting a JSON payload with project details
      id = params[:confirmation]
      attachments = params[:attachments]

      if id && attachments
        project = service.find_project_without_security(id)
        submission = project.asite_submissions.sent.last
        if project && submission
          check_submission(submission, attachments)
        else
          # project not found or no submission for project
          head :not_found, content_type: "application/json"
        end
      else
        # no id or attachments in payload
        head :bad_request, content_type: "application/json"
      end
    end

    private

    def check_submission(submission, attachments)
      state = submission.submission_state
      if state.can_confirm? || state.can_reject?
        submission.confirmation_received_at = Time.zone.now
        if attachments.count == submission.asite_files.count
          valid = 0
          attachments.each do |a|
            f = submission.asite_files.find_by(filename: a["filename"])
            break unless f && f.checksum == a["checksum"]

            valid += 1
          end
          if valid == submission.asite_files.count
            # all files have been validated
            state.confirm!
            head :no_content, content_type: "application/json"
          else
            # one or more checksums invalid
            state.reject!
            head :unprocessable_entity, content_type: "application/json"
          end
        else
          # wrong number of attachments
          state.reject!
          head :unprocessable_entity, content_type: "application/json"
        end
      else
        # current state cannot transition to :succeeded or :failed
        head :unprocessable_entity, content_type: "application/json"
      end
    end

    def service
      @service ||= ProjectService.new
    end
  end
end
