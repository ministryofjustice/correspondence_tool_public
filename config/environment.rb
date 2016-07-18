# Load the Rails application.
require_relative 'application'


Rails.configuration.action_mailer.smtp_settings = {
    :address              => "smtp.sendgrid.net",
    :port                 => 587,
    :domain               => 'digital.justice.gov.uk',
    :user_name            => ENV['CORRESPONDENCE_EMAIL_USERNAME'],
    :password             => ENV['CORRESPONDENCE_EMAIL_PASSWORD'],
    :authentication       => :plain,
    :enable_starttls_auto => true
}

# Initialize the Rails application.
Rails.application.initialize!
