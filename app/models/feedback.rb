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
  validates :ease_of_use, inclusion: {
    in: Settings.feedback_options,
    message: "Ease of use is not included in the list",
  }

  validates :completeness, inclusion: {
    in: Settings.feedback_options,
    message: "Completeness is not included in the list",
  }

  jsonb_accessor :content,
                 old_rating: [:string, { store_key: :rating }],
                 ease_of_use: :string,
                 completeness: :string,
                 comment: :text
end
