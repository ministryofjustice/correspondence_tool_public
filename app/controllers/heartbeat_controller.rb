class HeartbeatController < ApplicationController
  require "sidekiq/api"

  respond_to :json

  def ping
    version_info = {
      build_date: Settings.build_date,
      git_commit: Settings.git_commit,
      git_source: Settings.git_source,
    }

    render json: version_info
  end

  def healthcheck
    checks = {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq: sidekiq_alive?,
    }

    status = :bad_gateway unless checks.values.all?
    render status:, json: {
      checks:,
    }
  end

private

  def redis_alive?
    Sidekiq.redis(&:info)
    true
  rescue StandardError
    false
  end

  def sidekiq_alive?
    ps = Sidekiq::ProcessSet.new
    !ps.empty?
  rescue StandardError
    false
  end

  def sidekiq_queue_healthy?
    dead = Sidekiq::DeadSet.new
    retries = Sidekiq::RetrySet.new
    dead.empty? && retries.empty?
  rescue StandardError
    false
  end

  def database_alive?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end
end
