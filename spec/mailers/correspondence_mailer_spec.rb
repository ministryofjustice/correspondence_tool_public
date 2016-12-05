require "rails_helper"

RSpec.describe CorrespondenceMailer, type: :mailer do

  def send_email
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @correspondence = build(:correspondence, category: correspondence_category)
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
    let(:correspondence_category) { 'general_enquiries' }

    it 'sends an email' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    describe 'destination mail address' do
      subject { @mail.to }

      context 'when creating a general enquiry' do
        let(:correspondence_category) { 'general_enquiries' }
        it { is_expected.to include('general_enquiries@localhost') }
      end

      context 'when creating a foi request' do
        let(:correspondence_category) { 'freedom_of_information_request' }
        it { is_expected.to include('foi_request@localhost') }
      end

      context 'when creating a smoke test' do
        let(:correspondence_category) { 'smoke_test' }
        it { is_expected.to include('smoketest@localhost') }
      end

    end

    context 'and the subject contains' do

      it 'the category of correspondence' do
        expect(@mail.subject).to include(@correspondence.category.humanize)
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
