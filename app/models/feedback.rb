# == Schema Information
#
# Table name: feedback
#
#  id         :integer          not null, primary key
#  content    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Feedback < ApplicationRecord
  validates :ease_of_use, :completeness, inclusion: {
    in: Settings.feedback_options,
  }

  jsonb_accessor :content,
                 old_rating: [:string, { store_key: :rating }],
                 ease_of_use: :string,
                 completeness: :string,
                 comment: :text
end
