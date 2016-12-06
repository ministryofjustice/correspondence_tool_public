#!/usr/bin/env rails runner
# coding: utf-8

require 'optparse'
require 'ostruct'
require 'securerandom'

begin
  require 'mail'
  require 'mechanize'
rescue LoadError
  $stderr.error'!!! do you need to use RAILS_ENV=test ???'
  raise
end


CMDLINE_OPTIONS = YAML.load <<EOYAML
mail_server:
    short:  '-s'
    long:   '--mail-server=SERVER'
    help:   'Server to collect mail from.'
    envvar: 'SETTINGS__SMOKE_TESTS__SERVER'
mail_port:
    short:  '-p'
    long:   '--mail-port=PORT'
    help:   'Port to connect to mail server with.'
    envvar: 'SETTINGS__SMOKE_TESTS__PORT'
mail_ssl:
    short:  '-S'
    long:   '--[no-]mail-use-ssl'
    help:   'Whether to connect to mail server with SSL.'
    envvar: 'SETTINGS__SMOKE_TESTS__SSL'
mail_username:
    short:  '-U'
    long:   '--mail-username=USERNAME'
    help:   'Username to use with mail server.'
    envvar: 'SETTINGS__SMOKE_TESTS__USERNAME'
mail_password:
    short:  '-P'
    long:   '--mail-password=PASSWORD'
    help:   'Password to use with mail server.'
    envvar: 'SETTINGS__SMOKE_TESTS__PASSWORD'
first_read_wait:
    short:  '-F'
    long:   '--first-read-wait=SECONDS'
    help:   'Time to wait before attempting to read mail.'
    envvar: 'SETTINGS__SMOKE_TESTS__FIRST_READ_WAIT'
max_wait_time:
    short:  '-w'
    long:   '--max-wait-time=SECONDS'
    type:   !ruby/class 'Numeric'
    help:   'Maximum amount of time to wait for mail receipt.'
    envvar: 'SETTINGS__SMOKE_TESTS__MAX_WAIT_TIME'
EOYAML


module SmokeTest
  def self.main(args)
    remaining_args = parse_options(args)
    parse_args(remaining_args)
    configure_mailer(options)

    info 'Sending smoke test email'
    result = send_smoke_test_email(@@site_url)

    if result.code != '200'
      error "!!! HTTP Status: #{result.code}"
      result.response.each_pair { |header,value| error "#{header}: #{value}" }
      error result.pretty_inspect
      exit 2
    end


    info "Checking for email with message: #{message}"
    unless check_for_email message:         message,
                           first_read_wait: options.first_read_wait,
                           max_wait_time:   options.max_wait_time
      error '!!! Unable to find our email.'
      exit 3
    end
  end

  def self.options
    @@options ||= OpenStruct.new(
      mail_server:     Settings['smoke_tests']['server'],
      mail_port:       Settings['smoke_tests']['port'],
      mail_protocol:   Settings['smoke_tests']['protocol'],
      mail_ssl:        Settings['smoke_tests']['ssl'],
      mail_username:   Settings['smoke_tests']['username'],
      mail_password:   Settings['smoke_tests']['password'],
      first_read_wait: Settings['smoke_tests']['first_read_wait'],
      max_wait_time:   Settings['smoke_tests']['max_wait_time']
    )
  end

  def self.uuid
    @@uuid = SecureRandom.uuid
  end

  def self.message
    @@message ||= "This is smoky #{uuid}"
  end

  def self.create_options(opts)
    CMDLINE_OPTIONS.each do |name, option|
      usage = "#{option['help']}  [#{options[name]}]  #{option['envvar']}"
      type = option.fetch('type', String)
      opts.on(option['short'], option['long'], type, usage) do |val|
        options[name] = val
      end
    end
  end

  def self.parse_options(args)
    @@option_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: smoketest.rb [options]'

      opts.on('-h', '--help', 'Help.') do
        puts opts.help
        exit 0
      end
    end
    create_options @@option_parser
    @@option_parser.parse(args)
  end

  def self.parse_args(args)
    @@site_url = args.shift

    if @@site_url.nil?
      error '!!! No site_url provided'
      error @@option_parser.help
      exit 1
    end
  end

  def self.configure_mailer(opts)
    Mail.defaults do
      retriever_method :pop3,
                       address:    opts.mail_server,
                       port:       opts.mail_port,
                       enable_ssl: opts.mail_ssl,
                       user_name:  opts.mail_username,
                       password:   opts.mail_password
    end
  end

  def self.send_smoke_test_email(site_url)
    agent = Mechanize.new
    if ENV.has_key? 'http_proxy'
      (proxy_host, proxy_port) = ENV['http_proxy'].split ':'
      agent.set_proxy proxy_host, proxy_port
    end
    agent.get(site_url)
    page = agent.click('Start now')
    form = page.form_with id: 'new_correspondence'

    form.field_with(name: 'correspondence[name]').value = 'Smoke Test'
    form.field_with(name: 'correspondence[email]')
      .value = 'correspondence-dev@digital.justice.gov.uk'
    form.field_with(name: 'correspondence[email_confirmation]')
      .value = 'correspondence-dev@digital.justice.gov.uk'
    form.field_with(name: 'correspondence[message]').value = message
    form.field_with(name: 'correspondence[topic]')
      .value = 'This is smoke test #{uuid}'
    form.add_field!('smoke_test', :true)

    agent.submit form
  end

  def self.check_for_email(message:,
                           first_read_wait:,
                           max_wait_time:)
    start_time = Time.now
    info "Waiting #{first_read_wait}s for mail delivery to do it's thing."
    sleep first_read_wait
    try = 0
    while(Time.now - start_time < max_wait_time) do
      try += 1
      print "Email check #{try}: "
      if Mail.last(count: 3).detect { |mail| mail.body.include? message }
        info 'success'
        return true
      end
      wait_time = 1 + ((Time.now - start_time) ** 0.5)
      info 'failed. Sleeping %0.2fs.' % wait_time
      sleep wait_time
    end
    return false
  end

  def self.info(message)
    puts message
  end

  def self.error(message)
    $stderr.puts message
  end
end


if File.basename($0) == File.basename(__FILE__)
  SmokeTest.main(ARGV)
end

