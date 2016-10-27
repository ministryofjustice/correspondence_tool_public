require 'feedback'

class EmailFeedbackJob < ApplicationJob
  queue_as :mailers

  def perform(feedback_yaml)
    feedback = YAML.load(feedback_yaml)
    FeedbackMailer.new_feedback(feedback).deliver_now
  end
end
