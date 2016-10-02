class Feedback

  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :rating, :comment

  validates :rating, inclusion: { in:  Settings.service_feedback,
                                  message: "please select one option"}

end
