require 'rails_helper'

RSpec.describe EmailFeedbackJob, type: :job do
  let(:mail_double) { double('Mail::Message', deliver_now: true)}
  let(:feedback)    { create(:feedback) }
  subject           { EmailFeedbackJob.new }

  before do
    allow(FeedbackMailer).to receive(:new_feedback)
                               .and_return(mail_double)
  end

  describe '.perform_later' do
    it 'adds a job to our queue' do
      expect { EmailFeedbackJob.perform_later(feedback) }
        .to have_enqueued_job.on_queue('mailers')
    end
  end

  describe '#perform' do
    it 'sends an email' do
      subject.perform(feedback.id)
      expect(mail_double).to have_received(:deliver_now)
    end
  end
end
