class SentryContextProvider
  def self.set_context(_controller = nil)
    Sentry.set_extras(
      host_environment: ENV["ENV"] || "Not set",
      build_date: ENV["APP_BUILD_DATE"],
      git_commit_sha: ENV["APP_GIT_COMMIT"],
    )
  end
end
