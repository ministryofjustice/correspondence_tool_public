require 'rails_helper'

RSpec.describe Feedback, type: :model do

  subject { build :feedback }

    it { should be_valid }
    it { should validate_inclusion_of(:rating).in_array Settings.service_feedback }

  describe 'Feedback env variable is not null' do
    it 'has a specific email address associated' do
      expect(Settings.aaq_feedback_email).not_to be nil
    end
  end

end
