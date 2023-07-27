Sentry.init do |config|
    config.dsn = 'https://ea2d904892c54e25954261508b9c1ccf@o345774.ingest.sentry.io/5407958'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
end