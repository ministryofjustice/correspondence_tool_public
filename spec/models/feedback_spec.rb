# == Schema Information
#
# Table name: feedback
#
#  id         :integer          not null, primary key
#  content    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

RSpec.describe Feedback, type: :model do
  subject(:feedback) { build :feedback }

  it { is_expected.to be_valid }

  it do
    expect(feedback).to validate_inclusion_of(:ease_of_use).in_array Settings.feedback_options
    expect(feedback).to validate_inclusion_of(:completeness).in_array Settings.feedback_options
  end

  describe "Feedback env variable is not null" do
    it "has a specific email address associated" do
      expect(Settings.aaq_feedback_email).not_to be nil
    end
  end
end
