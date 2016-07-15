# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Rails.configuration.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => ENV['CORRESPONDENCE_EMAIL_FROM'],
    :password             => ENV['CORRESPONDENCE_EMAIL_PASSWORD'],
    :authentication       => :plain,
    :enable_starttls_auto => true
}
