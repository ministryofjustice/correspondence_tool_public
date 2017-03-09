# == Schema Information
#
# Table name: correspondence
#
#  id         :integer          not null, primary key
#  content    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Correspondence, type: :model do
  subject { build :correspondence }

  it { should be_valid }

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


end
