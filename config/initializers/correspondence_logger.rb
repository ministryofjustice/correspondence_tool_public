Rails.application.configure do
  filename = Rails.env.test? ? 'test_correspondence.log' : 'correspondence.log'
  Settings.correspondence_log = File.join('log', filename)
  config.correspondence_logger = ActiveSupport::Logger.new(Settings.correspondence_log)
end
