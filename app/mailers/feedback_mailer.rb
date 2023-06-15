class FeedbackMailer < GovukNotifyRails::Mailer
  def new_feedback(feedback)
    set_template Settings.new_feedback_notify_template

    set_personalisation ease_of_use: feedback.ease_of_use.humanize,
                        completeness: feedback.completeness.humanize,
                        comment: feedback.comment,
                        when_submitted: feedback.created_at

    mail to: Settings.aaq_feedback_email
  end
end
