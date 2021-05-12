source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'config'
gem 'curb', '~> 0.9.11'
gem 'foreman', '~> 0.82.0' # Used in dev & production
gem 'govuk_template',         '~> 0.24.1'
gem 'govuk_frontend_toolkit', '5.0.2'
gem 'govuk_elements_rails',   '2.2.1'
gem 'govuk_elements_form_builder', '0.1.1'
gem 'govuk_notify_rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'
gem 'jquery-rails'
gem 'jsonb_accessor', '~> 1.1.0'
gem 'listen', '~> 3.4.1'
gem 'logstasher'
gem 'mail', '~> 2.7.0'
gem 'mechanize', '~> 2.8'
gem 'puma', '~> 5.3'
gem 'pg', '~> 1.2'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rack", ">= 2.1.4"
gem 'rails', '~> 5.2.5'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'responders', '~> 3.0'
gem 'sass-rails', '~> 6.0'
gem 'sidekiq', '~> 6.2'
gem 'slim-rails', '~> 3.2'
# Used for the GOVUK Search API
gem 'stopwords-filter', require: 'stopwords'
gem 'susy', '~> 2.2.14'
gem 'uglifier', '>= 1.3.0'
gem 'sprockets', '~> 3.7.2'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'codeclimate-test-reporter', '~> 1.0'
  gem 'i18n-tasks', '~> 0.9.33'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver', '~> 3.14'
  gem 'shoulda-matchers', :git => 'https://github.com/thoughtbot/shoulda-matchers.git'
  gem 'site_prism', '~> 3.7'
  gem 'poltergeist', '~> 1.18'
  gem 'timecop', '~> 0.9'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'launchy', '~> 2.4', '>= 2.4.3'
  gem 'faker'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rb-readline', '~> 0.5.4'
  gem 'rspec-rails', '~> 4.0'
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
  gem 'web-console'
  gem 'annotate'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
