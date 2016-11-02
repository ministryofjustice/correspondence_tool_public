require "rails_helper"

RSpec.describe FeedbackMailer, type: :mailer do

  before(:each) do
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @feedback = build(:feedback)
    FeedbackMailer.new_feedback(@feedback).deliver_now
    @mail = ActionMailer::Base.deliveries.first
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe '#new_feedback' do

    it 'should send an email' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it 'should send to the correct address' do
      expect(@mail.to).to eq [ 'feedback@localhost' ]
    end

    describe 'and the subject contains' do
      it 'the rating for ease of use' do
        expect(@mail.subject).to include(@feedback.ease_of_use.humanize)
      end

      it 'the rating for completeness' do
        expect(@mail.subject).to include(@feedback.completeness.humanize)
      end
    end

    describe 'and the body contains' do
      it 'the rating for eash of use' do
        expect(@mail.html_part.body.to_s).
          to include(@feedback.ease_of_use.humanize)
      end

      it 'the rating for completeness' do
        expect(@mail.html_part.body.to_s).
          to include(@feedback.completeness.humanize)
      end

      it 'the comment' do
        expect(@mail.html_part.body.to_s).
          to include(@feedback.comment)
      end
    end
  end
end
