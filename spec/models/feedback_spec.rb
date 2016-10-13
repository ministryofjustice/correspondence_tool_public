require 'rails_helper'

RSpec.describe Feedback, type: :model do

  let(:feedback) { build :feedback }

  describe 'has a factory' do
    it 'that produces a valid object by default' do
      expect(feedback).to be_valid
    end
  end


  describe 'Feedback env variable is not null' do
    it 'has a specific email address associated' do
      expect(Settings.aaq_feedback_email).not_to be nil
    end
  end

  describe 'attributes' do

    it do
      should validate_inclusion_of(:rating).
        in_array( Settings.service_feedback)
    end
  end

end
