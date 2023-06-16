class ApplicationMailer < ActionMailer::Base
  default from: Settings.correspondence_email_from
  layout "mailer"
end
