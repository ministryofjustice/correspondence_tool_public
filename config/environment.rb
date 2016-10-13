# Load the Rails application.
require_relative 'application'


Rails.configuration.action_mailer.smtp_settings = {
    :address              => "smtp.sendgrid.net",
    :port                 => 587,
    :domain               => 'digital.justice.gov.uk',
    :user_name            => Settings.sendgrid_username,
    :password             => Settings.sendgrid_password,
    :authentication       => :plain,
    :enable_starttls_auto => true
}

Rails.configuration.action_mailer.default_url_options = {
  host: Settings.aaq_email_url
}

# Initialize the Rails application.
Rails.application.initialize!
