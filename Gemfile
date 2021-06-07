source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'config'
gem 'curb', '~> 0.9.11'
gem 'foreman', '~> 0.87.2' # Used in dev & production
gem 'govuk_template', '~> 0.26.0'
gem 'govuk_frontend_toolkit', '9.0.0'
gem 'govuk_elements_rails', '2.2.1'
gem 'govuk_elements_form_builder', '0.1.1'
gem 'govuk_notify_rails', '>= 2.1.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'
gem 'jquery-rails', '>= 4.4.0'
gem 'jsonb_accessor', '~> 1.3.2'
gem 'listen', '~> 3.5.1'
gem 'logstasher'
gem 'mail', '~> 2.7.0'
gem 'mechanize', '~> 2.8', '>= 2.8.1'
gem 'puma', '~> 5.3', '>= 5.3.1'
gem 'pg', '~> 1.2'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rack", ">= 2.1.4"
gem 'rails', '~> 5.2.6'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'responders', '~> 3.0', '>= 3.0.1'
gem 'sass-rails', '~> 6.0', '>= 6.0.0'
gem 'sidekiq', '~> 6.2'
gem 'slim-rails', '~> 3.2', '>= 3.2.0'
# Used for the GOVUK Search API
gem 'stopwords-filter', require: 'stopwords'
gem 'susy', '~> 2.2.14'
gem 'uglifier', '>= 1.3.0'
gem 'sprockets', '~> 3.7.2'
# Alpine does not include zoneinfo files (probably) - it asked for tinfo-data, so bundle the tzinfo-data gem
gem 'tzinfo-data'
gem 'webdrivers', '~> 4.4'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :test do
  gem 'capybara', '>= 3.35.3'
  gem 'capybara-selenium'
  gem 'capybara-screenshot'
  gem 'codeclimate-test-reporter', '~> 1.0'
  gem 'i18n-tasks', '~> 0.9.34'
  gem 'rails-controller-testing', '>= 1.0.5'
  gem 'selenium-webdriver', '~> 3.14'
  gem 'shoulda-matchers', :git => 'https://github.com/thoughtbot/shoulda-matchers.git'
  gem 'site_prism', '~> 3.7', '>= 3.7.1'
  gem 'timecop', '~> 0.9'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'launchy', '~> 2.4', '>= 2.4.3'
  gem 'faker'
  gem 'factory_bot_rails', '>= 6.2.0'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rb-readline', '~> 0.5.4'
  gem 'rspec-rails', '~> 5.0'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-performance', require: false
  gem 'awesome_print', '~> 1.7'
end

group :development do
  gem 'brakeman'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'guard-livereload', '>= 2.5.2'
  gem 'guard-rspec'
  gem 'guard-rubocop'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.1'
  gem 'web-console', '>= 3.7.0'
  gem 'annotate'
end
