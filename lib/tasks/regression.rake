namespace :regression do
  desc "Smoke-test the public correspondence journey (start -> topic -> search -> " \
       "contact form -> send) against a deployed Contact MoJ environment. Does not " \
       "touch this app's local Rails environment, database, or the confirmation email " \
       "- that step still needs to be checked by hand. Prompts interactively (press " \
       "Enter to accept the default shown, where there is one) for anything not " \
       "already set via env var: CONTACT_MOJ_URL (required), CONTACT_MOJ_TEST_EMAIL " \
       "(required), CONTACT_MOJ_BASIC_AUTH_USER / CONTACT_MOJ_BASIC_AUTH_PASS (if the " \
       "environment is behind Basic Auth), CONTACT_MOJ_TEST_NAME, CONTACT_MOJ_TOPIC, " \
       "CONTACT_MOJ_MESSAGE, CONTACT_MOJ_HEADLESS=false (to watch it run). Never commit " \
       "real values for these. Pass CONTACT_MOJ_DEFAULT=true to skip the 'use defaults?' " \
       "prompt and answer yes automatically - Rake treats --default as its own CLI flag " \
       "and will reject it, so it can't be passed that way."
  # rubocop:disable Rails/RakeEnvironment -- deliberately standalone, doesn't touch this app's Rails env/DB
  task :live_contact_moj_check do
    require "capybara"
    require "selenium-webdriver"
    require "net/http"
    require "uri"
    require "io/console"
    require "fileutils"

    use_defaults = %w[true 1 yes y].include?(ENV["CONTACT_MOJ_DEFAULT"].to_s.downcase)
    if !use_defaults && $stdin.tty?
      print "Use default values for everything except the environment URL and test email? [Y/n]: "
      answer = $stdin.gets&.chomp
      use_defaults = answer.blank? || !answer.strip.downcase.start_with?("n")
    end

    # Falls back to an interactive prompt (masked for `secret`, Enter accepts the
    # default shown) only when the env var is unset and we have a real terminal.
    # Fields with an actual default value are skipped entirely (silently using
    # it) when `use_defaults` was accepted above - fields with no default (e.g.
    # Basic Auth, which has nothing safe to fall back to) still get asked.
    ask = lambda do |env_name, label, default: nil, secret: false, required: false|
      env_value = ENV[env_name]
      next env_value if env_value.present?
      next default if use_defaults && !required && !default.nil?
      next default unless $stdin.tty?

      default_hint =
        if default
          " [#{secret ? 'hidden' : default}]"
        end
      print "#{label}#{default_hint}: "
      input = secret ? $stdin.noecho(&:gets) : $stdin.gets
      puts if secret
      input&.chomp.presence || default
    end

    base_url = ask.call("CONTACT_MOJ_URL", "Environment URL", required: true) ||
      abort("Set CONTACT_MOJ_URL, e.g. https://development.contact-moj.service.justice.gov.uk")
    test_email = ask.call("CONTACT_MOJ_TEST_EMAIL", "Test email address", required: true) ||
      abort("Set CONTACT_MOJ_TEST_EMAIL to the inbox that should receive the confirmation email")
    basic_auth_user = ask.call("CONTACT_MOJ_BASIC_AUTH_USER", "Basic Auth username (blank if none)")
    basic_auth_pass = ask.call("CONTACT_MOJ_BASIC_AUTH_PASS", "Basic Auth password (blank if none)", secret: true)
    test_name = ask.call("CONTACT_MOJ_TEST_NAME", "Full name to submit", default: "Test Testerson")
    test_topic = ask.call("CONTACT_MOJ_TOPIC", "Topic to search for", default: "Visiting a prison")
    test_message = ask.call(
      "CONTACT_MOJ_MESSAGE",
      "Message to submit",
      default: "This is a test message sent as part of manual regression testing of the Contact MoJ service. Please disregard.",
    )
    headless = ask.call("CONTACT_MOJ_HEADLESS", "Run headless? (true/false)", default: "false") != "false"

    uri = URI.parse(base_url)
    uri.user = basic_auth_user if basic_auth_user
    uri.password = basic_auth_pass if basic_auth_pass
    app_host = uri.to_s

    Capybara.register_driver :regression_chrome do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      if headless
        options.add_argument("--headless")
        options.add_argument("--disable-gpu")
        options.add_argument("--no-sandbox")
      end
      options.add_argument("--window-size=1280,1024")
      Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
    end

    Capybara.app_host = app_host
    Capybara.run_server = false
    Capybara.default_max_wait_time = 10

    session = nil

    begin
      puts "== Contact MoJ live regression check =="
      puts "Target: #{base_url}"
      puts "Test email: #{test_email}"
      puts

      # Small/dev environments can sleep when idle or occasionally serve a blank
      # response, so the first load can fail - retry a few times with a fresh
      # browser tab and a longer wait rather than failing the whole run on that.
      max_attempts = 3
      attempt = 0
      begin
        attempt += 1
        session&.driver&.quit
        session = Capybara::Session.new(:regression_chrome)
        Capybara.using_wait_time(attempt == 1 ? 10 : 30) do
          session.visit("/")
          session.click_on("Start now")
        end
      rescue Capybara::ElementNotFound
        raise if attempt >= max_attempts

        puts "Start page didn't load (attempt #{attempt}/#{max_attempts}) - retrying with a fresh tab..."
        sleep 5
        retry
      end

      session.fill_in("correspondence-topic-field", with: test_topic)
      session.click_button("Continue")

      puts "Checking self-service result links resolve..."
      session.all(:css, "ul.govuk-list.search-results li a").each do |link| # rubocop:disable Rails/FindEach -- Capybara::Result, not an AR relation
        href = link[:href]
        next unless href&.start_with?("http")

        begin
          response = Net::HTTP.get_response(URI.parse(href))
          puts "  #{response.code} #{href}"
        rescue StandardError => e
          puts "  ERROR #{href} (#{e.message})"
        end
      end

      session.find(:css, 'label[for="correspondence-contact-requested-no-field"]').click
      raise "FAIL: selecting 'No' did not reveal the self-service thank you content" \
        unless session.has_content?("Thank you for using this service")

      puts "'No' path reveals self-service content: OK"

      session.find(:css, 'label[for="correspondence-contact-requested-yes-field"]').click
      session.fill_in("correspondence-name-field", with: test_name)
      session.fill_in("correspondence-email-field", with: test_email)
      session.fill_in("correspondence-message-field", with: test_message)
      session.click_button("Send")

      unless session.has_content?("One more step...") && session.has_content?("We've sent an email to #{test_email}")
        raise "FAIL: did not reach the 'One more step...' confirmation page"
      end

      puts
      puts "Message submitted OK."
      puts "Confirmation page: #{session.current_url}"
      puts
      puts "Next: check #{test_email} for a GOV.UK Notify email (subject 'Confirm your email address')"
      puts "and open the 'Send my message to the Ministry of Justice' link to complete authentication."
    rescue StandardError => e
      puts
      puts "FAILED: #{e.class}: #{e.message}"
      if session
        puts "Current URL: #{session.current_url}"
        timestamp = Time.now.strftime("%Y%m%d%H%M%S") # rubocop:disable Rails/TimeZone -- local filename timestamp, Rails.application isn't initialized in this standalone task
        FileUtils.mkdir_p("tmp")
        screenshot_path = File.join("tmp", "regression_failure_#{timestamp}.png")
        html_path = File.join("tmp", "regression_failure_#{timestamp}.html")
        session.save_screenshot(screenshot_path)
        File.write(html_path, session.html)
        puts "Screenshot saved to #{screenshot_path}"
        puts "Page HTML saved to #{html_path}"
      end
      raise
    ensure
      session&.driver&.quit
    end
  end
  # rubocop:enable Rails/RakeEnvironment
end
