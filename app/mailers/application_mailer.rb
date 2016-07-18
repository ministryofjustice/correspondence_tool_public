class ApplicationMailer < ActionMailer::Base
  default from: ENV['CORRESPONDENCE_EMAIL_FROM']
  layout 'mailer'
end
