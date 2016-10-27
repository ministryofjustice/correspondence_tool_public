class Feedback < ActiveRecord::Base
  validates :rating, inclusion: {
              in:      Settings.service_feedback,
              message: 'please select one option'
            }

  jsonb_accessor :content,
    rating: :string,
    comment: :text
end
