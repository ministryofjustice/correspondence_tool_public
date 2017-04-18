require 'rails_helper'

describe CorrespondenceCreator do

  describe '.new' do
    context 'no radio button selected' do

      let(:params) { { 'contact_requested' => 'no' } }

      it 'returns :no_op' do
        creator = CorrespondenceCreator.new(params)
        expect(creator.result).to eq :no_op
      end

      it 'does not create a correspondence item' do
        expect {
          CorrespondenceCreator.new(params)
        }.to change {Correspondence.count }.by(0)
      end
    end

    context 'valid correspondence object created' do
      let(:params) do
        {
          'name' => 'Joe',
          'email' => 'aa@aa.com',
          'topic' => 'my topic',
          'message' => 'My message',
          'category' => 'general_enquiries'
        }
      end

      it 'returns :success' do
        creator = CorrespondenceCreator.new(params)
        expect(creator.result).to eq :success
      end

      it 'sends confirmation email' do
        expect(EmailConfirmationJob).to receive(:perform_later).with(instance_of(Correspondence))
        CorrespondenceCreator.new(params)
      end

      it 'saves a new correspondence object' do
        expect {
          CorrespondenceCreator.new(params)
        }.to change {Correspondence.count }.by(1)
      end

      it 'adds a uuid' do
        allow(SecureRandom).to receive(:uuid).and_return('ffffffff-eeee-dddd-cccc-bbbbbbbbbbb')
        CorrespondenceCreator.new(params)
        expect(Correspondence.last.uuid).to eq 'ffffffff-eeee-dddd-cccc-bbbbbbbbbbb'
      end
    end

    context 'Invalid params' do
      let(:params) do
        { 'name' => 'Joe' }
      end

      it 'returns :validation_error' do
        creator = CorrespondenceCreator.new(params)
        expect(creator.result).to eq :validation_error
      end

      it 'does not save a correspondence obejct' do
        expect {
          CorrespondenceCreator.new(params)
        }.to change { Correspondence.count }.by(0)
      end
    end
  end

end
