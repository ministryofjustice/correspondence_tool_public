require "rails_helper"

RSpec.describe CorrespondenceMailer, type: :mailer do
  describe "#new_correspondence" do
    let(:correspondence_category) { "general_enquiries" }
    let(:correspondence) do
      create :correspondence,
             category: correspondence_category,
             email: "tester@localhost",
             name: "Testy McTest Face",
             message: "this is just a test",
             created_at:
                   Time.zone.local(2017, 3, 3, 15, 3, 57),
             topic: "testing correspondence mailing"
    end
    let(:mail) { described_class.new_correspondence(correspondence) }

    it "sets the template" do
      expect(mail.govuk_notify_template)
        .to eq "29ad44f7-ba74-455c-9f8e-e2d72c933620"
    end

    it "personalises the email" do
      expect(mail.govuk_notify_personalisation)
        .to eq({
          topic: "testing correspondence mailing",
          category: "General enquiries",
          correspondent_name: "Testy McTest Face",
          correspondent_email: "tester@localhost",
          message: "this is just a test",
          when_submitted: "03/03/2017 15:03",
        })
    end

    describe "destination mail address" do
      subject { mail.to }

      context "when creating a general enquiry" do
        let(:correspondence_category) { "general_enquiries" }

        it {
          expect(subject).to include(Settings.general_enquiries_email)
        }
      end

      context "when creating a foi request" do
        let(:correspondence_category) { "freedom_of_information_request" }

        it { is_expected.to include("foi_request@localhost") }
      end

      context "when creating a smoke test" do
        let(:correspondence_category) { "smoke_test" }

        it { is_expected.to include(Settings.smoke_tests.username) }
      end
    end
  end
end
