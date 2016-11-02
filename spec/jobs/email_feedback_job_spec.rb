require 'rails_helper'

RSpec.describe EmailFeedbackJob, type: :job do
  let(:feedback) { create(:feedback) }
  subject        { EmailFeedbackJob.new }

  describe '.perform_later' do
    it 'adds a job to our queue' do
      expect { EmailFeedbackJob.perform_later(feedback) }
        .to have_enqueued_job.on_queue('mailers')
    end
  end

  describe '#perform' do
    it 'sends an email' do
      expect { subject.perform(feedback.id) }
        .to change { ActionMailer::Base.deliveries.count }.by 1
    end
  end
end
