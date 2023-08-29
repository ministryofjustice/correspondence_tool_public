source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false
gem "config"
gem "curb", "~> 1.0", ">= 1.0.5"
gem "foreman", "~> 0.87.2" # Used in dev & production
gem "govuk_elements_form_builder", "0.1.1"
gem "govuk_elements_rails", "2.2.1"
gem "govuk_frontend_toolkit", "9.0.1"
gem "govuk_notify_rails", ">= 2.1.2"
gem "govuk_template", "~> 0.26.0"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11"
gem "jquery-rails", ">= 4.4.0"
gem "jsonb_accessor", "~> 1.3.4"
gem "listen", "~> 3.8.0"
gem "logstasher"
gem "mail", ">= 2.8"
gem "mechanize", "~> 2.8"
gem "pg", "~> 1.3"
gem "prometheus_exporter"
gem "puma", "~> 5.6"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1", ">= 6.1.7.3"
gem "responders", "~> 3.0", ">= 3.0.1"
gem "sass-rails", "~> 6.0", ">= 6.0.0"
gem "sentry-rails"
gem "sentry-ruby"
gem "sidekiq", "~> 6.4"
gem "slim-rails", "~> 3.6"
gem "sprockets", "~> 3.7.2"
# Used for the GOVUK Search API
gem "stopwords-filter2", require: "stopwords"
# Alpine does not include zoneinfo files (probably) - it asked for tinfo-data, so bundle the tzinfo-data gem
gem "tzinfo-data"
gem "uglifier", ">= 1.3.0"
gem "webdrivers", "~> 5.0"

group :test do
  gem "capybara", ">= 3.35.3"
  gem "capybara-screenshot"
  gem "capybara-selenium"
  gem "i18n-tasks", "~> 1.0.12"
  gem "rails-controller-testing", ">= 1.0.5"
  gem "selenium-webdriver", "~> 4.1.0"
  gem "shoulda-matchers"
  gem "simplecov", "~> 0.21.2"
  gem "site_prism", "~> 3.7"
  gem "timecop", "~> 0.9"
end

group :development, :test do
  gem "awesome_print", "~> 1.7"
  gem "brakeman"
  gem "debug", ">= 1.0.0"
  gem "factory_bot_rails", ">= 6.2.0"
  gem "faker"
  gem "rspec-rails", "~> 5.1"
  gem "rubocop-govuk", require: false
end

group :development do
  gem "annotate"
  gem "better_errors"
  gem "binding_of_caller"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.1"
end
