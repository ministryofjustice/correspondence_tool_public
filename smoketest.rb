#!/usr/bin/env rails runner

begin
  require 'mail'
  require 'mechanize'
rescue LoadError
  $stderr.puts '!!! please use RAILS_ENV=test !!!'
  raise
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
  smoke_test_email = Mail::Address.new Settings['smoke_test_email']

  retriever_method :pop3, address:    Settings['smoke_tests']['server'],
                          port:       Settings['smoke_tests']['port'],
                          enable_ssl: Settings['smoke_tests']['ssl'],
                          user_name:  smoke_test_email.local,
                          password:   Settings['smoke_tests']['password']
end

puts "Checking for email with message: #{message}"
unless check_for_email(
         message:         message,
         read_attempts:   Settings['smoke_tests']['read_attempts'],
         first_read_wait: Settings['smoke_tests']['first_read_wait'],
         retry_read_wait: Settings['smoke_tests']['retry_read_wait'],
       )
  puts '!!! Unable to find our email.'
  exit 3
end

