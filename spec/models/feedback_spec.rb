require 'rails_helper'

RSpec.describe Feedback, type: :model do
  subject { build :feedback }

  it { should be_valid }
  it do
    should validate_inclusion_of(:ease_of_use).in_array Settings.feedback_options
    should validate_inclusion_of(:completeness).in_array Settings.feedback_options
  end

  describe 'Feedback env variable is not null' do
    it 'has a specific email address associated' do
      expect(Settings.aaq_feedback_email).not_to be nil
    end
  end
end
