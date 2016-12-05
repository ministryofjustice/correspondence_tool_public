require 'rails_helper'

RSpec.describe EmailConfirmationJob, type: :job do
  let(:correspondence) { create(:correspondence) }
  subject              { EmailConfirmationJob.new }

  describe '.perform_later' do
    it 'enqueues a job' do
      expect { EmailConfirmationJob.perform_later(correspondence) }
        .to have_enqueued_job.on_queue('mailers')
    end
  end

  describe '#perform' do
    it 'sends an email' do
      expect { subject.perform(correspondence.id) }
        .to change { ActionMailer::Base.deliveries.count }.by 1
    end
  end
end

