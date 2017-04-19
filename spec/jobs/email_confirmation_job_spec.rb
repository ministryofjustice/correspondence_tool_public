require 'rails_helper'

RSpec.describe EmailConfirmationJob, type: :job do
  let(:mail_double)    { double('Mail::Message', deliver_now: true)}
  let(:correspondence) { create(:correspondence) }
  subject              { EmailConfirmationJob.new }

  before do
    allow(ConfirmationMailer).to receive(:new_confirmation)
                                   .and_return(mail_double)
  end

  describe '.perform_later' do
    it 'enqueues a job' do
      expect { EmailConfirmationJob.perform_later(correspondence) }
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

