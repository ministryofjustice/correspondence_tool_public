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

# Locally there's no metrics sidecar on port 9394, so Prometheus clients log
# repeated "Connection refused" errors. Start the exporter in-process for
# development only to give them a collector and silence those errors.
#
# Once running, metrics are available at http://localhost:9394/metrics
#
# Source: https://www.rubydoc.info/gems/govuk_app_config/9.24.1
if Rails.env.development?
  require "govuk_app_config/govuk_prometheus_exporter"
  GovukPrometheusExporter.configure
end
