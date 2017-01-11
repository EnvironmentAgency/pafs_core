# frozen_string_literal: true
require "rails_helper"

module PafsCore
  RSpec.describe AsiteMailer, type: :mailer do
    describe "submit_project" do
      before(:each) do
        ENV["DEVISE_MAIL_SENDER"] = "no-reply@example.com"
        ENV["BACKUP_MAIL_RECIPIENT"] = "backup@example.com"
      end

      let(:ref_no) { "AB501C-0000A-0001A" }
      let(:files) { Hash.new }
      let(:mail) { described_class.submit_project(ref_no, files).deliver_now }

      it "uses the reference number as the subject" do
        expect(mail.subject).to eq(ref_no)
      end

      it "uses the no-reply address as the sender" do
        expect(mail.from).to include "no-reply@example.com"
      end

      it "sends the email to the BACKUP_MAIL_RECIPIENT" do
        expect(mail.to).to include ENV.fetch("BACKUP_MAIL_RECIPIENT")
      end
    end
  end
end
