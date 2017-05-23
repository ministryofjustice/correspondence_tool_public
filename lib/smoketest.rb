require 'mail'
require 'mechanize'
require 'securerandom'



class Smoketest

  def initialize
    puts "Smoketest running in #{Rails.env} mode!"
    @env_vars_ok = true
    check_settings
    @pop_mail_server = Settings.smoke_tests.server
    @mailbox = Settings.smoke_tests.username
    @mailbox_password = Settings.smoke_tests.password
    @site_url = Settings.smoke_tests.site_url
    @message_uuid = SecureRandom.uuid
    @message = "Smoketest correspondence item with message data #{@message_uuid}"
    configure_mailer
  end

  def run
    uuid = submit_new_correspondence_item
    authentication_link = check_confirmation_mail_recieved(uuid)
    click_auth_link(authentication_link)
    mail = check_new_correspondence_item_mail(@message)
    if mail == false
      puts "!!! ERROR - Unable to find confirmation email to DACU with message #{@message}"
      exit 2
    end
    puts "!!! SMOKETEST SUCCESSFUL"
  end

  private

  def submit_new_correspondence_item
    agent = Mechanize.new
    if ENV.has_key? 'http_proxy'
      (proxy_host, proxy_port) = ENV['http_proxy'].split ':'
      agent.set_proxy proxy_host, proxy_port
    end
    agent.get(@site_url)
    page = agent.click('Start now')
    form = page.form_with id: 'new_correspondence'

    form.field_with(name: 'correspondence[topic]').value = 'Smoke Test'
    page = agent.submit form

    form = page.form_with id: 'new_correspondence'
    form.radiobutton_with(id: 'correspondence_contact_requested_yes').click

    form.field_with(name: 'correspondence[name]').value = 'Smoking Tester'
    form.field_with(name: 'correspondence[email]').value = @mailbox
    form.field_with(name: 'correspondence[message]').value = @message
    form.add_field!('smoke_test', :true)
    response = agent.submit form
    puts "Correspondence item with message data #{@message_uuid} submitted at #{Time.now.strftime('%H:%M:%S')}."

    if response.code != '200'
      error "!!! HTTP Status: #{result.code} when submitting correspondence item"
      result.response.each_pair { |header,value| error "#{header}: #{value}" }
      error result.pretty_inspect
      exit 2
    end

    uuid = extract_uuid_from_page(response)
    puts "Correspondence item with UUID #{uuid} successfully submitted"
    uuid
  end

  def extract_uuid_from_page(page)
    div = page.search('div.uuid')
    div.attr('data-uuid').text
  end


  def check_confirmation_mail_recieved(uuid)
    link = "/correspondence/authenticate/#{uuid}"
    info "Checking for confirmation mail with link #{link}"
    mail = check_mail_received_with_contents(link)
    if mail == false
      puts "!!! ERROR Unable to find authentication mail"
      exit 4
    else
      puts "Confirmation mail detected at #{Time.now.strftime('%H:%M:%S')}"
    end
    "#{@site_url}#{link}"
  end

  def check_new_correspondence_item_mail(message)
    info "Checking for mail to DACU wil message: #{message}"
    mail = check_mail_received_with_contents(message)
    if mail == false
      puts "!!! ERROR Unable to find DACU mail"
      exit 4
    else
      puts "DACU mail detected at #{Time.now.strftime('%H:%M:%S')}"
    end
  end

  def check_mail_received_with_contents(contents)
    start_time = Time.now
    info "Waiting #{Settings.smoke_tests.first_read_wait}s for mail delivery to do it's thing."
    sleep Settings.smoke_tests.first_read_wait
    try = 0
    while(Time.now - start_time < Settings.smoke_tests.max_wait_time) do
      try += 1
      print "Email check #{try}: "
      mail = Mail.last(count: 3).detect { |m| m.body.include?(contents) }
      if mail
        info 'success'
        return mail
      end
      wait_time = try + ((Time.now - start_time) ** 0.5)
      info 'failed. Sleeping %0.2fs.' % wait_time
      sleep wait_time
    end
    return false
  end

  def info(message)
    puts message
  end

  def configure_mailer
    pop_mail_server = @pop_mail_server.clone
    mailbox = @mailbox.clone
    mailbox_password = @mailbox_password.clone
    Mail.defaults do
      retriever_method :pop3,
                       address:    pop_mail_server,
                       port:       Settings.smoke_tests.port,
                       enable_ssl: Settings.smoke_tests.ssl,
                       user_name:  mailbox,
                       password:   mailbox_password
    end
  end

  def click_auth_link(authentication_link)
    agent = Mechanize.new
    response = agent.get(authentication_link)

    if response.code != '200'
      error "!!! HTTP Status: #{result.code} when clicking on authentication link"
      result.response.each_pair { |header,value| error "#{header}: #{value}" }
      error result.pretty_inspect
      exit 2
    end

    if response.body !~ /Your message has been sent/
      info "!!! Unable to find 'Thank you for authenticating your request' in page after authenticating"
      puts response.body
      exit 2
    end
  end

  def check_settings
    if Settings.smoke_tests.username.nil?
      missing_env_var('SMOKE_TESTS__USERNAME')
    end
    if Settings.smoke_tests.password.nil?
      missing_env_var('SMOKE_TESTS__PASSWORD')
    end
    if Settings.smoke_tests.server.nil?
      missing_env_var('SMOKE_TESTS__SERVER')
    end
    if Settings.smoke_tests.site_url.nil?
      missing_env_var('SMOKE_TESTS__SITE_URL')
    end
    unless @env_vars_ok
      puts "Fix environment variables before proceeding"
      exit 2
    end
  end


  def missing_env_var(var)
    info "!!! ERROR - Environment variable SETTINGS__#{var} not set!"
    @env_vars_ok = false
  end

end



