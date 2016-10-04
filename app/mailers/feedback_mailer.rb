class FeedbackMailer < ApplicationMailer

  def new_feedback(feedback)
    @feedback = feedback
    mail to: ENV['AAQ_FEEDBACK_EMAIL'],
         subject: "Ask Tool Feedback - #{@feedback.rating.humanize}"
  end

end
