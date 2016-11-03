#!/usr/bin/env rails runner

require 'optparse'
require 'ostruct'

options = OpenStruct.new(
  mail_server:     Settings['smoke_tests']['server'],
  mail_port:       Settings['smoke_tests']['port'],
  mail_protocol:   Settings['smoke_tests']['protocol'],
  mail_ssl:        Settings['smoke_tests']['ssl'],
  mail_username:   Settings['smoke_tests']['username'],
  mail_password:   Settings['smoke_tests']['password'],
  read_attempts:   Settings['smoke_tests']['read_attempts'],
  first_read_wait: Settings['smoke_tests']['first_read_wait'],
  retry_read_wait: Settings['smoke_tests']['retry_read_wait']
)

opts = OptionParser.new do |opts|
  opts.banner = 'Usage: smoketest.rb [options]'

  opts.on('-h', '--help', 'Help.') do
    puts opts.help
    exit 0
  end

  def create_settings_option(opts, options, short, long, help, setting, envvar)
    opts.on(short, long, "#{help}  [#{options[setting]}]  #{envvar}") do |val|
      options[setting] = val
    end
  end

  create_settings_option opts, options, '-s', '--mail-server=SERVER',
                         'Server to contact.',
                         :mail_server,
                         'SETTINGS__SMOKE_TESTS__SERVER'

  create_settings_option opts, options, '-p', '--mail-port=PORT',
                         'Port to connect to mail server with.',
                         :mail_port,
                         'SETTINGS__SMOKE_TESTS__PORT'

  create_settings_option opts, options, '-S', '--[no-]mail-use-ssl',
                         'Whether to connect to mail server with SSL.',
                         :mail_ssl,
                         'SETTINGS__SMOKE_TESTS__SSL'

  create_settings_option opts, options, '-U', '--mail-username=USERNAME',
                         'Username to use with mail server.',
                         :mail_username,
                         'SETTINGS__SMOKE_TESTS__USERNAME'

  create_settings_option opts, options, '-P', '--mail-password=PASSWORD',
                         'Password to use with mail server.',
                         :mail_password,
                         'SETTINGS__SMOKE_TESTS__PASSWORD'

  create_settings_option opts, options, '-c', '--read-attempts=COUNT',
                         'Number of times to attempt reading email.',
                         :read_attempts,
                         'SETTINGS__SMOKE_TESTS__READ_ATTEMPTS'

  create_settings_option opts, options, '-F', '--first-read-wait=SECONDS',
                         'Time to wait before attempting to read mail.',
                         :first_read_wait,
                         'SETTINGS__SMOKE_TESTS__FIRST_READ_WAIT'

  create_settings_option opts, options, '-R', '--retry-read-wait=SECONDS',
                         'Time to wait before retry reading email.',
                         :retry_read_wait,
                         'SETTINGS__SMOKE_TESTS__RETRY_READ_WAIT'
end
opts.parse!


begin
  require 'mail'
  require 'mechanize'
rescue LoadError
  $stderr.puts '!!! please use RAILS_ENV=test !!!'
  raise
end

site_url = ARGV.shift

if site_url.nil?
  $stderr.puts "No site_url provided"
  $stderr.puts opts.help
  exit 1
end

def send_smoke_test_email(site_url, message)
  agent = Mechanize.new
  if ENV.has_key? 'http_proxy'
    (proxy_host, proxy_port) = ENV['http_proxy'].split ':'
    agent.set_proxy proxy_host, proxy_port
  end
  page = agent.get(site_url)
  form = page.form_with id: 'new_correspondence'

  form.field_with(name: 'correspondence[name]').value = 'Smoke Test'
  form.field_with(name: 'correspondence[email]')
    .value = 'correspondence-dev@digital.justice.gov.uk'
  form.field_with(name: 'correspondence[email_confirmation]')
    .value = 'correspondence-dev@digital.justice.gov.uk'
  form.field_with(name: 'correspondence[message]').value = message
  form.radiobutton_with(name: 'correspondence[topic]', value: 'legal_aid').check
  form.add_field!('smoke_test', :true)

  agent.submit form
end


def check_for_email(message:, read_attempts:, first_read_wait:, retry_read_wait:)
  puts "Waiting #{first_read_wait}s for mail delivery to do it's thing."
  sleep first_read_wait
  read_attempts.times do |try|
    print "Email check #{try}: "
    if Mail.last(count: 3).detect { |mail| mail.body.include? message }
      puts 'success'
      return true
    else
      puts "failed. Sleeping #{retry_read_wait}s."
    end
    sleep retry_read_wait
  end
  return false
end


message = "This is smoky #{Process.pid} #{DateTime.now}"
site_url = 'http://127.0.0.1:5000'
puts 'Sending smoke test email'
result = send_smoke_test_email(site_url, message)

if result.code != '200'
  puts "!!! HTTP Status: #{result.code}"
  result.response.each_pair { |header,value| puts "#{header}: #{value}" }
  puts result.pretty_inspect
  exit 2
end


Mail.defaults do
  retriever_method :pop3, address:    options.mail_server,
                          port:       options.mail_port,
                          enable_ssl: options.mail_ssl,
                          user_name:  options.mail_username,
                          password:   options.mail_password
end

puts "Checking for email with message: #{message}"
unless check_for_email(
         message:         message,
         read_attempts:   options.read_attempts,
         first_read_wait: options.first_read_wait,
         retry_read_wait: options.retry_read_wait,
       )
  puts '!!! Unable to find our email.'
  exit 3
end

