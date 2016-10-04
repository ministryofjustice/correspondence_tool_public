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
      expect(@mail.to).to eq [ ENV['AAQ_FEEDBACK_EMAIL'] ]
    end

    it 'should have a subject that contains the rating' do
      expect(@mail.subject).to include(@feedback.rating.humanize)
    end

  end

end
