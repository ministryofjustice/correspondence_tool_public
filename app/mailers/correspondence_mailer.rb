require 'correspondence'

class CorrespondenceMailer < GovukNotifyRails::Mailer

  def new_correspondence(correspondence)
    set_template(Settings.new_correspondence_notify_template)

    set_personalisation category:            correspondence.category.humanize,
                        topic:               correspondence.topic,
                        correspondent_name:  correspondence.name,
                        correspondent_email: correspondence.email,
                        message:             correspondence.message,
                        when_submitted:      l(correspondence.created_at)

    mail to: Settings["#{correspondence.category}_email"]
  end

end
