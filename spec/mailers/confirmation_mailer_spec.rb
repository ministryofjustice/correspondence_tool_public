require "rails_helper"

RSpec.describe ConfirmationMailer, type: :mailer do

  def send_email
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @correspondence = build(:correspondence, category: correspondence_category)
    ConfirmationMailer.new_confirmation(@correspondence).deliver_now
    @mail = ActionMailer::Base.deliveries.first
  end

  before(:each) do
    send_email
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  let(:expected_message)  do
    [ "To #{@correspondence.name}",
      'Thank you for contacting the Ministry of Justice.',
      'Our team will be checking what you have sent us shortly.',
      'We aim to get back to you within 1 month, if we are able to respond to you',
      'MOJ team',
      'Do not reply to this email.',
      'This address is not checked by the Ministry of Justice'
    ]
  end

  describe '#new_confirmation' do
    let(:correspondence_category) { 'general_enquiries' }

    it 'sends an email' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    describe 'sender email address' do
      subject { @mail.from }

      it { is_expected.to include('noreply@digital.justice.gov.uk') }

    end

    describe 'destination mail address' do
      subject { @mail.to }

      it { is_expected.to include(@correspondence.email) }
    end

    describe 'and the subject' do
      it 'confirms receipt of the message' do
        expect(@mail.subject).to include('We have received your enquiry')
      end
    end

    describe 'and the body' do
      it 'contains a message from a member of the public' do
        expected_message.each do |line|
          expect(@mail.html_part.body.to_s).to include(line)
        end
      end
    end
  end
end
