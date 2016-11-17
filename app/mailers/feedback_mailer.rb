class FeedbackMailer < ApplicationMailer

  def new_feedback(feedback)
    @feedback = feedback
    ease = @feedback.ease_of_use.humanize
    complete = @feedback.completeness.humanize
    mail to: Settings.aaq_feedback_email,
         subject: "Ask Tool Feedback - Easy: #{ease} - Complete: #{complete}"
  end

end
