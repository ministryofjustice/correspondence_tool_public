source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false
gem "config"
gem "curb", "~> 1.0", ">= 1.0.5"
gem "foreman", "~> 0.87.2" # Used in dev & production
gem "govuk-components"
gem "govuk_elements_form_builder", "0.1.1"
gem "govuk_elements_rails", "2.2.1"
gem "govuk_frontend_toolkit", "9.0.1"
gem "govuk_notify_rails", ">= 2.1.2"
gem "govuk_template", "~> 0.26.0"
gem "jquery-rails", ">= 4.4.0"
gem "jsonb_accessor", "~> 1.4"
gem "logstasher"
gem "mail", ">= 2.8"
gem "mechanize", "~> 2.12"
gem "pg", "~> 1.5"
gem "prometheus_exporter"
gem "puma"
gem "rails", "~> 7.0"
gem "responders", "~> 3.0", ">= 3.0.1"
gem "sass-rails", "~> 6.0", ">= 6.0.0"
gem "sentry-rails"
gem "sentry-ruby"
gem "sidekiq", "~> 6.5"
gem "slim-rails", "~> 3.6"
gem "sprockets", "~> 3.7.3"
# Used for the GOVUK Search API
gem "stopwords-filter2", require: "stopwords"
gem "terser"
# Alpine does not include zoneinfo files (probably) - it asked for tinfo-data, so bundle the tzinfo-data gem
gem "tzinfo-data"

group :test do
  gem "capybara", ">= 3.35.3"
  gem "i18n-tasks"
  gem "rails-controller-testing", ">= 1.0.5"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "site_prism", "~> 4.0"
  gem "timecop"
end

group :development, :test do
  gem "awesome_print", "~> 1.7"
  gem "brakeman"
  gem "debug"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
  gem "rubocop-govuk", require: false
end

group :development do
  gem "annotate"
  gem "better_errors"
  gem "binding_of_caller"
end
