#!/usr/bin/env ruby

require 'mail'
require 'mechanize'
# require 'nokogiri'
require 'pry'

site_url = 'http://127.0.0.1:5000'

agent = Mechanize.new
if ENV.has_key? 'http_proxy'
  (proxy_host, proxy_port) = ENV['http_proxy'].split ':'
  agent.set_proxy proxy_host, proxy_port
end
page = agent.get(site_url)

f = page.form_with id: 'new_correspondence'

f.field_with(name: 'correspondence[name]').value = 'Misha'
f.field_with(name: 'correspondence[email]')
  .value = 'misaka@pobox.com'
f.field_with(name: 'correspondence[email_confirmation]')
  .value = 'misaka@pobox.com'
f.field_with(name: 'correspondence[message]')
  .value = 'This is only a test'
f.radiobutton_with(name: 'correspondence[topic]', value: 'legal_aid').check
f.add_field!('smoke_test', :true)

result = agent.submit f

pp result

Mail.defaults do
  retriever_method :pop3, :address    => 'pop.gmail.com',
                          :port       => 995,
                          :user_name  => '',
                          :password   => 'correspondencetool2016',
                          :enable_ssl => true
end

# puts Mail.first.inspect



