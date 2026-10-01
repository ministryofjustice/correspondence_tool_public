class HeartbeatController < ApplicationController
  require "sidekiq/api"

  respond_to :json

  def ping
    render json: { status: "ok" }
  end

  def healthcheck
    @errors = []

    checks = {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq: sidekiq_alive?,
    }

    if checks.values.all?
      status = :ok
    else
      status = :internal_server_error
      Sentry.capture_message("HealthCheck failed: #{@errors}")
    end

    render status:, json: { status: status == :ok ? "ok" : "error" }
  end

private

  def redis_alive?
    Sidekiq.redis { |conn| conn.call("INFO") }
    true
  rescue StandardError => e
    log_unknown_error(e)
    false
  end

  def sidekiq_alive?
    ps = Sidekiq::ProcessSet.new
    !ps.size.zero? # rubocop:disable Style/ZeroLengthPredicate
  rescue StandardError => e
    log_unknown_error(e)
    false
  end

  def database_alive?
    ActiveRecord::Base.connection.execute("select 1 as result")
  rescue StandardError => e
    log_unknown_error(e)
    false
  end

  def log_unknown_error(error)
    @errors << "Error: #{error.message}\nDetails:#{error.backtrace}"
  end
end
