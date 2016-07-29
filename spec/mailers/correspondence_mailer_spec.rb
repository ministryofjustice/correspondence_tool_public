require "rails_helper"

RSpec.describe CorrespondenceMailer, type: :mailer do

  def send_email(correspondence_type='freedom_of_information_request')
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @correspondence = build(:correspondence, type: correspondence_type)
    CorrespondenceMailer.new_correspondence(@correspondence).deliver_now
    @mail = ActionMailer::Base.deliveries.first
  end

  before(:each) do
    send_email
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe '#new_correspondence' do

    it 'sends an email' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    context 'to the correct address for' do
      it 'freedom of information requests' do
        expect(@mail.to).to eq [ ENV['FREEDOM_OF_INFORMATION_REQUEST_EMAIL'] ]
      end

      it 'general_enquiries' do
        send_email('general_enquiries')
        expect(@mail.to).to eq [ ENV['GENERAL_ENQUIRIES_EMAIL'] ]
      end

    end

    context 'and the subject contains' do

      it 'the type of correspondence' do
        expect(@mail.subject).to include(@correspondence.type)
      end

      it 'the area of interest' do
        expect(@mail.subject).to include(@correspondence.topic)
      end
    end

    context 'and the body contains' do
      it 'a message from a member of the public' do
        expect(@mail.html_part.body.to_s).to include(@correspondence.message)
      end
    end

  end

end
