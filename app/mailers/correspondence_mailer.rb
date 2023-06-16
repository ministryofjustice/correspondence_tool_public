require "correspondence"

class CorrespondenceMailer < GovukNotifyRails::Mailer
  def new_correspondence(correspondence)
    set_template(Settings.new_correspondence_notify_template)

    set_personalisation category: correspondence.category.humanize,
                        topic: correspondence.topic,
                        correspondent_name: correspondence.name,
                        correspondent_email: correspondence.email,
                        message: correspondence.message,
                        when_submitted: l(correspondence.created_at)
    to_address = if correspondence.category == "smoke_test"
                   Settings.smoke_tests.username
                 else
                   Settings["#{correspondence.category}_email"]
                 end
    mail to: to_address
  end
end
