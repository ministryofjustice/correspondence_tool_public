source 'https://rubygems.org'

gem 'coffee-rails', '~> 4.2'
gem 'config'
gem 'foreman', '~> 0.82.0' # Used in dev & production
gem 'govuk_template',         '~> 0.19.1'
gem 'govuk_frontend_toolkit', '>= 5.0.2'
gem 'govuk_elements_rails',   '>= 2.2.1'
gem 'govuk_elements_form_builder', git: 'https://github.com/ministryofjustice/govuk_elements_form_builder.git'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'jsonb_accessor', '~> 1.0.0.beta.1'
gem 'logstasher'
gem 'premailer-rails', '~> 1.9'
gem 'puma', '~> 3.0'
gem 'pg', '~> 0.18'
gem 'rails', '~> 5.0.0'
gem 'responders', '~> 2.3'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'slim-rails', '~> 3.1'
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
  gem "codeclimate-test-reporter", require: nil
  gem 'i18n-tasks', '~> 0.9.5'
  gem 'mail'
  gem 'mechanize'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', '~> 3.1'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rb-readline'
  gem 'rspec-rails', '~> 3.4'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'guard-livereload', '>= 2.5.2'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
