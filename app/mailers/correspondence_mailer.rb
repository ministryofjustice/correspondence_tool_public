class CorrespondenceMailer < GovukNotifyRails::Mailer
  def new_correspondence(correspondence)
    set_template(Settings.new_correspondence_notify_template)

    set_personalisation category: correspondence.category.humanize,
                        topic: correspondence.topic,
                        correspondent_name: correspondence.name,
                        correspondent_email: correspondence.email,
                        message: correspondence.message,
                        when_submitted: l(correspondence.created_at)
    to_address = Settings["#{correspondence.category}_email"]
    mail to: to_address
  end
end
