if ENV["SENTRY_DSN"].present?
  return if %w[test development].include?(Rails.env)

  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
  end
end
