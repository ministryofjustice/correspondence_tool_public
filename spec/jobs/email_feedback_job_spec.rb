require 'rails_helper'

RSpec.describe EmailFeedbackJob, type: :job do
  
  let(:feedback) { create(:feedback) }
  subject        { EmailFeedbackJob.new }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform' do
    it 'sends an email' do
      expect { subject.perform(feedback.id) }
        .to change { ActionMailer::Base.deliveries.count }.by 1
    end
  end

  describe '.perform_later' do
    it 'accepts the ID of a feedback and enqueues an EmailFeedbackJob' do
      expect { EmailFeedbackJob.perform_later(feedback.id) }
        .to have_enqueued_job(EmailFeedbackJob)
    end
  end

end
