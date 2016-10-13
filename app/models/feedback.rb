class Feedback < ActiveRecord::Base

  validates :rating, inclusion: { in:  Settings.service_feedback,
                                  message: "please select one option"}

end
