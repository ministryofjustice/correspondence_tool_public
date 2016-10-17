class FeedbackMailer < ApplicationMailer

  def new_feedback(feedback)
    @feedback = feedback
    mail to: Settings.aaq_feedback_email,
         subject: "Ask Tool Feedback - #{@feedback.rating.humanize}"
  end

end
