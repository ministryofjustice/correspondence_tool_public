class HeartbeatController < ApplicationController
  require "sidekiq/api"

  respond_to :json

  def ping
    version_info = {
      build_date: Settings.build_date,
      git_commit: Settings.git_commit,
      build_tag: Settings.git_source,
    }

    render json: version_info
  end

  def healthcheck
    @errors = []

    checks = {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq: sidekiq_alive?,
    }

    unless checks.values.all?
      status = :internal_server_error
      Sentry.capture_message("HealthCheck failed: #{@errors}")
    end
    render status:, json: {
      checks:,
    }
  end

private

  def redis_alive?
    Sidekiq.redis(&:info)
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
    ActiveRecord::Base.connection.active?
  rescue StandardError => e
    log_unknown_error(e)
    false
  end

  def log_unknown_error(error)
    @errors << "Error: #{error.message}\nDetails:#{error.backtrace}"
  end
end
