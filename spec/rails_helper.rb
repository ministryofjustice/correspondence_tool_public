# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "spec_helper"
require "rspec/rails"
require "capybara/rails"
require "capybara/rspec"
require "capybara_screenshot_diff/rspec"

Capybara.asset_host = "http://localhost:3000"

Capybara::Screenshot::Diff.configure do |screenshot, diff|
  screenshot.window_size = [1280, 1024]
  screenshot.stability_time_limit = 1
  # The app's strict CSP (style-src :self, no nonce) blocks the gem's inline
  # <style> injection used to hide the text caret before capturing.
  screenshot.hide_caret = false
  diff.driver = :chunky_png
  diff.color_distance_limit = 15
  diff.tolerance = 0.01
end

# RECORD_SCREENSHOTS=1 regenerates baselines instead of failing when none
# exist yet. Used by .github/workflows/record-regression-baselines.yml,
# which runs on the same ubuntu-latest/Chrome combination as CI so captured
# baselines don't drift from a developer's local OS/font rendering.
Capybara::Screenshot::Diff.fail_if_new = false if ENV["RECORD_SCREENSHOTS"]

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  unless ENV["CHROME_DEBUG"]
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--start-maximized")
    options.add_argument("--window-size=1980,2080")
    options.add_argument("--enable-features=NetworkService,NetworkServiceInProcess")
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.default_max_wait_time = 4
Capybara.javascript_driver = :headless_chrome

Capybara.server = :puma, { Silent: true }

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#

# Load Site Prism
Dir[Rails.root.join("spec/site_prism/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include AskTool::Pages::Application

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = Rails.root.join("spec/fixtures")

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

require "ap"
