source 'https://rubygems.org'

gem 'coffee-rails', '~> 4.2'
gem 'config'
gem 'curb', '~> 0.9'
gem 'foreman', '~> 0.82.0' # Used in dev & production
gem 'govuk_template',         '~> 0.19.1'
gem 'govuk_frontend_toolkit', '>= 5.0.2'
gem 'govuk_elements_rails',   '>= 2.2.1'
gem 'govuk_elements_form_builder'
gem 'govuk_notify_rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'jsonb_accessor', '~> 1.0.0.beta.1'
gem 'listen', '~> 3.0.5'
gem 'logstasher'
gem 'mail', '~> 2.6.4'
gem 'mechanize', '~> 2.7.5'
gem 'premailer-rails', '~> 1.9'
gem 'puma', '~> 3.0'
gem 'pg', '~> 0.18'
gem 'rails', '~> 5.0.0'
gem 'responders', '~> 2.3'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq', '~> 5.1'
gem 'slim-rails', '~> 3.1'
# Used for the GOVUK Search API
gem 'stopwords-filter', require: 'stopwords'
gem 'susy', '~> 2.2.12'
gem 'uglifier', '>= 1.3.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem "codeclimate-test-reporter", require: nil
  gem 'i18n-tasks', '~> 0.9.5'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver', '~> 3.0'
  gem 'shoulda-matchers', :git => 'https://github.com/thoughtbot/shoulda-matchers.git'
  gem 'site_prism', '~> 2.9'
  gem 'poltergeist', '~> 1.13'
  gem 'timecop', '~> 0.8'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'launchy', '~> 2.4', '>= 2.4.3'
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rb-readline', '~> 0.5.4'
  gem 'rspec-rails', '~> 3.4'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
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
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
  gem 'annotate'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
