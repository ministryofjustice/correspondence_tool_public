Rails.application.configure do
  filename = Rails.env.test? ? 'test_service_feedback.log' : 'service_feedback.log'
  Settings.feedback_log = File.join('log', filename)
  config.feedback_logger = ActiveSupport::Logger.new(Settings.feedback_log)
end
