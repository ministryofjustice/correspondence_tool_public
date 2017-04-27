class ConfirmationMailer < GovukNotifyRails::Mailer
  def new_confirmation(correspondence)
    set_template Settings.correspondence_confirmation_notify_template

    authentication_link = correspondence_authentication_url(correspondence.uuid)
    set_personalisation name:                correspondence.name,
                        authentication_link: authentication_link,
                        confirmation_code:   correspondence.confirmation_code

    mail to: correspondence.email
  end

end

