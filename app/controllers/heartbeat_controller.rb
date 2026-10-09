class HeartbeatController < ApplicationController
  require "sidekiq/api"

  respond_to :json

  before_action :authenticate_deploy_dashboard!, only: :deploy_info

  def ping
    render json: { status: "ok" }
  end

  def deploy_info
    render json: {
      build_date: Settings.build_date,
      git_commit: Settings.git_commit,
      build_tag: Settings.git_source,
    }
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

  def authenticate_deploy_dashboard!
    expected_secret = ENV.fetch("DEPLOY_DASHBOARD_SHARED_SECRET", nil)
    provided_secret = request.headers["X-Deploy-Dashboard-Secret"]

    return if expected_secret.present? &&
      provided_secret.present? &&
      ActiveSupport::SecurityUtils.secure_compare(provided_secret, expected_secret)

    head :unauthorized
  end

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
