require 'rails_helper'

RSpec.describe EmailCorrespondenceJob, type: :job do
  
  let(:correspondence) { create(:correspondence) }
  subject              { EmailCorrespondenceJob.new }

  describe '#perform' do

    it 'sends an email' do
      expect { subject.perform(correspondence.id) }
        .to change { ActionMailer::Base.deliveries.count }.by 1
    end
  end

  describe '.perform_later' do

    it 'accepts the ID of a correspondence and enqueues a job' do
      expect { EmailCorrespondenceJob.perform_later(correspondence) }
        .to have_enqueued_job(EmailCorrespondenceJob)
    end
  end

end
