# == Schema Information
#
# Table name: correspondence
#
#  id               :integer          not null, primary key
#  content          :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  uuid             :string
#  authenticated_at :datetime
#

require 'rails_helper'

RSpec.describe Correspondence, type: :model do
  subject { build :correspondence }

  it { should be_valid }

  describe 'uuid' do
    let(:create_params) do
      {
        name: 'Same Mame',
        email: 'same.mame@localhost',
        category: 'general_enquiries',
        topic: 'some name game',
        message: 'This is some name game test.'
      }
    end

    it { should have_readonly_attribute :uuid }

    it 'sets a uuid' do
      allow(SecureRandom)
        .to receive(:uuid).and_return('ffffffff-eeee-dddd-cccc-bbbbbbbbbbb')
      correspondence = described_class.create! create_params
      expect(correspondence.uuid).to eq 'ffffffff-eeee-dddd-cccc-bbbbbbbbbbb'
    end

    it 'does not allow a caller to set uuid on creation' do
      allow(SecureRandom)
        .to receive(:uuid).and_return('ffffffff-eeee-dddd-cccc-bbbbbbbbbbb')
      correspondence = described_class.create!(
        create_params.merge(uuid: 'bbbbbbbbbbb-cccc-dddd-eeee-ffffffff')
      )
      expect(correspondence.uuid).to eq 'ffffffff-eeee-dddd-cccc-bbbbbbbbbbb'
    end
  end

  describe 'each category' do
    Settings.correspondence_categories.each do |category|
      it 'has a specific email address associated' do
        expect(Settings["#{category}_email"]).not_to be nil
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of     :name }
    it { should validate_presence_of     :email }
    it { should validate_presence_of     :category }
    it do
      should validate_presence_of(:topic).
          with_message(
              'Please tell us what your query is about.'
          )
    end
    it { should validate_presence_of     :message }
    it { should validate_confirmation_of :email}

    it do
      should validate_inclusion_of(:category).
        in_array(Settings.correspondence_categories)
    end

    it { should allow_value('foo@bar.com').for :email }
    it { should_not allow_value('foobar.com').for :email  }
    it { should validate_length_of(:topic).is_at_most(60) }
    it { should validate_length_of(:message).is_at_most(5000) }

    it { should validate_inclusion_of(:contact_requested).in_array(['yes', 'no']) }
  end

  describe '#topic_present?' do
    context 'topic present' do

      let(:correspondence) { build :correspondence, topic: 'My topic' }

      it 'returns true' do
        expect(correspondence.topic_present?).to be true
      end

      it 'has no error messages' do
        correspondence.topic_present?
        expect(correspondence.errors).to be_empty
      end
    end

    context 'topic absent' do
      let(:correspondence) { build :correspondence, topic: '' }

      it 'returns false' do
        expect(correspondence.topic_present?).to be false
      end

      it 'has an error messages' do
        correspondence.topic_present?
        expect(correspondence.errors[:topic]).to eq [" can't be blank"]
      end
    end
  end

  describe '#authenticated?' do
    context 'unauthenticated' do
      it 'returns false' do
        correspondence = build :correspondence
        expect(correspondence.authenticated?).to be false
      end
    end

    context 'authenticated' do
      it 'returns true' do
        correspondence = build :correspondence, :authenticated
        expect(correspondence.authenticated?).to be true
      end
    end
  end

  describe 'autenticate!' do
    let(:frozen_time) { Time.new(2017, 4, 13, 22, 33, 44) }

    context 'unauthenticated' do
      it 'updates authenticated_at with current time' do
        Timecop.freeze frozen_time do
          correspondence = build :correspondence
          correspondence.authenticate!
          expect(correspondence.authenticated_at).to eq frozen_time
        end
      end
    end

    context 'authenticated' do
      it 'does not update the authenticated at time' do
        correspondence = build :correspondence, authenticated_at: frozen_time
        correspondence.authenticate!
        expect(correspondence.authenticated_at).to eq frozen_time
      end
    end

  end


end
