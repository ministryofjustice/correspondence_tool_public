source 'https://rubygems.org'

gem 'coffee-rails', '~> 4.2'
gem 'config'
gem 'govuk_template',         '~> 0.18.0'
gem 'govuk_frontend_toolkit', '>= 4.13.0'
gem 'govuk_elements_rails',   '>= 1.2.1'
gem 'govuk_elements_form_builder', git: 'https://github.com/ministryofjustice/govuk_elements_form_builder.git'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'premailer-rails', '~> 1.9'
gem 'puma', '~> 3.0'
gem 'rails', '~> 5.0.0'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'slim-rails', '~> 3.1'
gem 'susy',	                  '~> 2.2.12'
gem 'uglifier', '>= 1.3.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem "foreman"

group :test do
  gem 'capybara'
  gem "codeclimate-test-reporter", require: nil
  gem 'rails-controller-testing'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.4'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'guard-livereload', '>= 2.5.2'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


#For Heroku
gem 'rails_12factor', group: :production
ruby "2.3.1"
