# Load the Rails application.
require_relative "application"

Rails.configuration.action_mailer.default_url_options = {
  host: Settings.aaq_email_url,
}

Rails.configuration.time_zone = "London"

# Initialize the Rails application.
Rails.application.initialize!
