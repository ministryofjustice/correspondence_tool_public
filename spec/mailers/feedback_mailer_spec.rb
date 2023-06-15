require "rails_helper"

RSpec.describe FeedbackMailer, type: :mailer do
  describe "#new_feedback" do
    let(:feedback) { create :feedback }
    let(:mail) { described_class.new_feedback(feedback) }

    it "uses the correct template" do
      expect(mail.govuk_notify_template)
        .to eq "2ddca175-7284-4343-9408-a7db23975269"
    end

    it "personalises the email" do
      expect(mail.govuk_notify_personalisation)
        .to eq({
          ease_of_use: feedback.ease_of_use.humanize,
          completeness: feedback.completeness.humanize,
          comment: feedback.comment,
          when_submitted: feedback.created_at,
        })
    end

    it "sends to the correct address" do
      expect(mail.to).to include Settings.aaq_feedback_email
    end
  end
end
