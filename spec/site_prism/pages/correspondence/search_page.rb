module AskTool
  module Pages
    module Correspondence
      class SearchPage < SitePrism::Page
        set_url '/correspondence/search'

        elements :self_service, 'ul.list li'
        elements :self_service_ga_events, 'ul.list li a[onclick]'
        element :self_serviced_radio, 'label[for="correspondence_contact_requested_no"]'
        element :self_serviced_radio_copy, '#correspondence_contact_requested_no_content'

        element :need_to_contact_radio, 'label[for="correspondence_contact_requested_yes"]'
        section :need_to_contact_form, '#correspondence_contact_requested_yes_content' do
          element :name, '#correspondence_name'
          element :email, '#correspondence_email'
          element :message, '#correspondence_message'
          element :counter, '.char-counter-count'
        end

        element :send_button, 'input[type="submit"][value="Send"]'

        def send_correspondence(name, email, message)
          need_to_contact_form.name.set name
          need_to_contact_form.email.set email
          need_to_contact_form.message.set message

          send_button.click

        end
      end
    end
  end
end

