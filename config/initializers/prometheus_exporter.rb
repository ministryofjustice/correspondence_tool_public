unless Rails.env.test? || Rails.env.development?
  require "prometheus_exporter/middleware"
  require "prometheus_exporter/instrumentation"

  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift PrometheusExporter::Middleware
  # this reports basic process stats like RSS and GC info
  PrometheusExporter::Instrumentation::Process.start(type: "master")

  if defined?(Sidekiq)
    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add PrometheusExporter::Instrumentation::Sidekiq
      end
      config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
      config.on :startup do
        PrometheusExporter::Instrumentation::Process.start(type: "sidekiq")
        PrometheusExporter::Instrumentation::SidekiqProcess.start
        PrometheusExporter::Instrumentation::SidekiqQueue.start
        PrometheusExporter::Instrumentation::SidekiqStats.start
      end
    end
  end
end
