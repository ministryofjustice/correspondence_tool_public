unless Rails.env == "test"
  require 'prometheus_exporter/middleware'
  require 'prometheus_exporter/instrumentation'

  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift PrometheusExporter::Middleware
  # this reports basic process stats like RSS and GC info
  PrometheusExporter::Instrumentation::Process.start(type: "master")
end

# # Per-process stats
# unless Rails.env == "test"
#   require 'prometheus_exporter/instrumentation'

#   # this reports basic process stats like RSS and GC info
#   PrometheusExporter::Instrumentation::Process.start(type: "master")
# end