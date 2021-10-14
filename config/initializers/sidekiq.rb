Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

Sidekiq.configure_server do |config|
  config.on :startup do
    require 'prometheus_exporter/instrumentation'

    # Activerecord Connection Pool Metrics
    PrometheusExporter::Instrumentation::ActiveRecord.start(
      custom_labels: { type: "sidekiq" }, #optional params
      config_labels: [:database, :host] #optional params
    )

    # To monitor Queue size and latency:
    PrometheusExporter::Instrumentation::SidekiqQueue.start
    # To monitor Sidekiq process info:
    PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'
  end

  config.server_middleware do |chain|
    require 'prometheus_exporter/instrumentation'
    # Including Sidekiq metrics (how many jobs ran? how many failed? how long did they take? how many are dead? how many were restarted?)
    chain.add PrometheusExporter::Instrumentation::Sidekiq
  end
  config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler

  # Sometimes the Sidekiq server shuts down before it can send metrics, that were generated right before the shutdown,
  # to the collector. Especially if you care about the sidekiq_restarted_jobs_total metric, it is a good idea to explicitly stop the client:
  at_exit do
    PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
  end

end

# # Including Sidekiq metrics (how many jobs ran? how many failed? how long did they take? how many are dead? how many were restarted?)
# Sidekiq.configure_server do |config|
#   config.server_middleware do |chain|
#      require 'prometheus_exporter/instrumentation'
#      chain.add PrometheusExporter::Instrumentation::Sidekiq
#   end
#   config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
# end

# # To monitor Queue size and latency:
# Sidekiq.configure_server do |config|
#   config.on :startup do
#     require 'prometheus_exporter/instrumentation'
#     PrometheusExporter::Instrumentation::SidekiqQueue.start
#   end
# end

# # To monitor Sidekiq process info:
# Sidekiq.configure_server do |config|
#   config.on :startup do
#     require 'prometheus_exporter/instrumentation'
#     PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'
#   end
# end

# # Sometimes the Sidekiq server shuts down before it can send metrics, that were generated right before the shutdown,
# # to the collector. Especially if you care about the sidekiq_restarted_jobs_total metric, it is a good idea to explicitly stop the client:

# Sidekiq.configure_server do |config|
#   at_exit do
#     PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
#   end
# end