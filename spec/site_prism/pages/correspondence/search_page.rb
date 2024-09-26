module AskTool
  module Pages
    module Correspondence
      class SearchPage < SitePrism::Page
        set_url "/correspondence/search"

        elements :self_service, "ul.govuk-list li"
        elements :self_service_ga_events, "ul.govuk-list li a[onclick]"
        element :self_serviced_radio, 'label[for="correspondence-contact-requested-no-field"]'
        element :self_serviced_radio_copy, "#correspondence_contact_requested_no_content"

        element :need_to_contact_radio, 'label[for="correspondence-contact-requested-yes-field"]'
        section :need_to_contact_form, "#correspondence_contact_requested_yes_content" do
          element :name, "#correspondence-name-field"
          element :email, "#correspondence-email-field"
          element :message, "#correspondence-message-field"
          element :counter, ".char-counter-count"
        end

        element :send_button, 'button[type="submit"]'

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
