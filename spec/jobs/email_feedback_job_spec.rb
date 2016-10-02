require 'rails_helper'

RSpec.describe EmailFeedbackJob, type: :job do
  
  let(:feedback) { build(:feedback) }

  describe '#perform_later' do

    before do
      @feedback_yaml = YAML.dump(feedback)
      ActiveJob::Base.queue_adapter = :test
    end

    it 'accepts a serialised object and adds a job to the queue' do
      expect { EmailFeedbackJob.perform_later(@feedback_yaml) }.to have_enqueued_job(EmailFeedbackJob)
    end
  end

end
