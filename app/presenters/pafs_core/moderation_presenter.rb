# frozen_string_literal: true
module PafsCore
  class ModerationPresenter < SimpleDelegator
    include PafsCore::Urgency

    def body
      f = PafsCore::Engine.root.join("app", "views", "pafs_core", "projects", "downloads", "moderation.txt.erb")
      s = ERB.new(IO.read(f)).result(binding)
      # make it friendly for the Winders users
      s.encode(s.encoding, crlf_newline: true)
    end

    def pretty_urgency_reason
      if urgency_reason.present?
        I18n.t("#{urgency_reason}_text", scope: "pafs_core.urgency_reasons.short")
      else
        ""
      end
    end

  private
    def project
      __getobj__
    end
  end
end
