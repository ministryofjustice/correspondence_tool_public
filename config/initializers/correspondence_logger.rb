Rails.application.configure do
  config.correspondence_logger = ActiveSupport::Logger.new('correspondence.log')
end
