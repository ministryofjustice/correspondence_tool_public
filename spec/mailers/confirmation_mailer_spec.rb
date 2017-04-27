require "rails_helper"

RSpec.describe ConfirmationMailer, type: :mailer do
  describe '#new_confirmation' do
    let(:correspondence) { create :correspondence,
                                  category: 'general_enquiries',
                                  email: 'tester@localhost',
                                  name: 'Testy McTest Face',
                                  message: 'this is just a test',
                                  created_at:
                                    DateTime.new(2017, 3, 3, 15, 3, 57),
                                  topic: 'testing correspondence mailing' }
    let(:mail) { described_class.new_confirmation(correspondence) }

    it 'sets the template' do
      expect(mail.govuk_notify_template)
        .to eq 'cfa41a99-a4d0-4a7f-8c69-3d5f097397a0'
    end

    it 'personalises the email' do
      expect(mail.govuk_notify_personalisation)
        .to eq({
                 name: 'Testy McTest Face',
                 authentication_link:
                   "http://localhost:3000/correspondence/authenticate/" \
                   + correspondence.uuid,
                 confirmation_code: correspondence.confirmation_code,
               })
    end

    it 'sets the To address' do
      expect(mail.to).to include 'tester@localhost'
    end
  end
end
