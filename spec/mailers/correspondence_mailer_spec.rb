require "rails_helper"

RSpec.describe CorrespondenceMailer, type: :mailer do

  before(:each) do
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @correspondence = build(:correspondence)
    CorrespondenceMailer.new_correspondence(@correspondence).deliver_now
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe '#new_correspondence' do
    it 'sends an email' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    context 'and the subject contains' do
      it 'the type of correspondence' do
        mail = ActionMailer::Base.deliveries.first
        expect(mail.subject).to include(@correspondence.type)
      end

      it 'the area of interest' do
        mail = ActionMailer::Base.deliveries.first
        expect(mail.subject).to include(@correspondence.sub_type)
      end
    end

    context 'and the body contains' do
      it 'a message from a member of the public' do
        mail = ActionMailer::Base.deliveries.first
        mail.html_part.body.to_s.include?(@correspondence.message)
      end
    end
  end

end
