source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "config"
gem "govuk_app_config", ">= 9.25.2"
gem "govuk-components", ">= 5.11.1"
gem "govuk_design_system_formbuilder"
gem "govuk_notify_rails", ">= 2.1.2"
gem "httparty"
gem "jsonb_accessor", "~> 1.4"
gem "logstasher", ">= 3.0.0"
gem "mail", ">= 2.8"
gem "ostruct"
gem "pg", "~> 1.5"
gem "rails", "~> 8.1.4"
gem "responders", "~> 3.2", ">= 3.2.1"
gem "sentry-sidekiq", ">= 6.7.0"
gem "sidekiq", "~> 8.1", ">= 8.1.7"
gem "slim-rails", "~> 4.0", ">= 4.0.0"
# Used for the GOVUK Search API
gem "stopwords-filter2", require: "stopwords"
gem "terser"
# Alpine does not include zoneinfo files (probably) - it asked for tinfo-data, so bundle the tzinfo-data gem
gem "tzinfo-data"

gem "cssbundling-rails"
gem "jsbundling-rails"
gem "sprockets", ">= 4.3.0"
gem "sprockets-rails"

group :test do
  gem "capybara", ">= 3.35.3"
  gem "capybara-screenshot-diff", "~> 1.15"
  gem "chunky_png"
  gem "i18n-tasks", ">= 1.2.0"
  gem "rails-controller-testing", ">= 1.0.5"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "site_prism", "~> 6.0"
  gem "timecop"
end

group :development, :test do
  gem "awesome_print", "~> 1.7"
  gem "brakeman"
  gem "debug"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry"
  gem "rspec-rails", ">= 8.0.5"
  gem "rubocop-govuk", ">= 6.0.0", require: false
end

group :development do
  gem "annotate"
  gem "better_errors"
  gem "binding_of_caller"
end
