require 'feedback'

class EmailFeedbackJob < ApplicationJob
  queue_as :mailers

  def perform(feedback_id)
    feedback = Feedback.find(feedback_id)
    FeedbackMailer.new_feedback(feedback).deliver_now
  end
end
