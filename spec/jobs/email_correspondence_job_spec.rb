require 'rails_helper'

RSpec.describe EmailCorrespondenceJob, type: :job do
  
  let(:correspondence) { build(:correspondence) }

  describe '#perform_later' do

    before do
      @correspondence_yaml = YAML.dump(correspondence)
      ActiveJob::Base.queue_adapter = :test
    end

    it 'accepts a serialised object and adds a job to the queue' do
      expect { EmailCorrespondenceJob.perform_later(@correspondence_yaml) }.to have_enqueued_job(EmailCorrespondenceJob)
    end
  end

end
