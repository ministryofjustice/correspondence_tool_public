require 'rails_helper'

RSpec.describe EmailCorrespondenceJob, type: :job do
  let(:mail_double)    { double('Mail::Message', deliver_now: true)}
  let(:correspondence) { create(:correspondence) }
  subject              { EmailCorrespondenceJob.new }

  before do
    allow(CorrespondenceMailer).to receive(:new_correspondence)
                                     .and_return(mail_double)
  end

  describe '.perform_later' do
    it 'enqueues a job' do
      expect { EmailCorrespondenceJob.perform_later(correspondence) }
        .to have_enqueued_job.on_queue('mailers')
    end
  end

  describe '#perform' do
    it 'sends an email' do
      subject.perform(correspondence.id)
      expect(mail_double).to have_received(:deliver_now)
    end
  end
end
