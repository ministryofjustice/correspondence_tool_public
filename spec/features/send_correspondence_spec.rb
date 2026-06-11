require "rails_helper"

feature "Submit a general enquiry" do
  given(:name)               { Faker::Name.name                   }
  given(:email)              { Faker::Internet.email              }
  given(:message)            { Faker::Lorem.paragraphs[1]         }
  given(:topic_with_results) { "Visiting a prison" }

  given(:topic_error) do
    "What are you contacting the Ministry of Justice about? can't be blank"
  end

  given(:error_messages) do
    [
      "Full name can't be blank",
      "Email can't be blank",
      "Your message can't be blank",
    ]
  end

  given(:success_messages) do
    [
      "One more step...",
      "We've sent an email to #{email}",
      "Go to your inbox and click the link in the email.",
      "You must click the link in your email to send your message to the Ministry of Justice.",
      "This is to check that your email address is valid.",
    ]
  end

  scenario 'User should start at the service "Start page"' do
    start_page.load
    expect(start_page.title).to eq "Start - Contact the Ministry of Justice"
    expect(start_page).to have_content("Help us make this service better. Give us your feedback.")

    expect(start_page).to have_related_items
    expect(start_page.related_items).to have_find_a_court
    expect(start_page.related_items).to have_find_a_prison
    expect(start_page.related_items).to have_visit_a_prison
    expect(start_page.related_items.other_services.size).to eq 3

    start_page.start_button.click
    expect(topic_page).to be_displayed
    expect(topic_page.title).to eq "Topic search - Contact the Ministry of Justice"
  end

  scenario "self-service - searching govuk service" do
    topic_page.load
    expect(topic_page.title).to eq "Topic search - Contact the Ministry of Justice"
    topic_page.search_govuk(topic_with_results)

    expect(search_page).to be_displayed
    expect(search_page.title).to eq "Contact form - Contact the Ministry of Justice"
    expect(search_page.self_service.size).to eq 4
    expect(search_page.self_service_ga_events.size).to eq 4
  end

  scenario "Selecting 'No' shows content with next step links", :js do
    topic_page.load
    topic_page.search_govuk(topic_with_results)

    expect(search_page).to be_displayed
    expect(search_page).to have_self_serviced_radio

    search_page.self_serviced_radio.click
    search_page.wait_until_self_serviced_radio_copy_visible

    no_content = search_page.self_serviced_radio_copy

    expect(no_content).to have_content("Thank you for using this service")
    expect(no_content).to have_content("You are free to close this window or do something else:")
    expect(no_content).to have_link("Start again with a new reason for contacting MoJ", href: "/")
    expect(no_content).to have_link("Give feedback on this service (takes 30 seconds)", href: "https://www.smartsurvey.co.uk/s/SU2UAX/")
    expect(no_content).to have_link("Return to the Ministry of Justice home page", href: "https://www.gov.uk/government/organisations/ministry-of-justice")
  end

  scenario "Using valid inputs", :js do
    topic_page.load
    expect(topic_page.title).to eq "Topic search - Contact the Ministry of Justice"
    topic_page.search_govuk(topic_with_results)

    expect(search_page).to be_displayed
    expect(search_page.title).to eq "Contact form - Contact the Ministry of Justice"

    expect(search_page).to have_self_serviced_radio

    # If GOVUK API results helped the user
    search_page.self_serviced_radio.click
    search_page.wait_until_self_serviced_radio_copy_visible

    # If GOVUK API results did not help the user
    search_page.need_to_contact_radio.click
    search_page.wait_until_need_to_contact_form_visible

    search_page.send_correspondence(name,
                                    email,
                                    message)

    success_messages.each do |success_message|
      expect(page).to have_content(success_message)
    end

    expect(Correspondence.count).to eq 1
    expect(Correspondence.last).to have_attributes(
      name:,
      email:,
      message:,
      topic: topic_with_results,
    )
    expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.with("ConfirmationMailer", "new_confirmation", "deliver_now", args: anything).at_least(:once)
  end

  scenario "Without a topic, name, email address, confirm email or message" do
    topic_page.load

    expect(topic_page.title).to eq "Topic search - Contact the Ministry of Justice"

    topic_page.search_govuk("")
    expect(topic_page.text).to have_content(topic_error)

    expect(search_page.title).to eq "Topic search - Contact the Ministry of Justice"

    topic_page.search_govuk(topic_with_results, topic_page.topic_field_error)

    expect(search_page.title).to eq "Contact form - Contact the Ministry of Justice"

    search_page.need_to_contact_radio.click

    search_page.wait_until_need_to_contact_form_visible

    click_button "Send"

    expect(search_page).to have_error_summary
    error_messages.each do |error_message|
      expect(search_page.error_summary).to have_link(error_message)
    end

    expect(search_page.need_to_contact_form.name_error.text).to eq "Error: Full name can't be blank"
    expect(search_page.need_to_contact_form.email_error.text).to eq "Error: Email can't be blank"
    expect(search_page.need_to_contact_form.message_error.text).to eq "Error: Your message can't be blank"
  end

  scenario "A topic which returns zero results" do
    topic_page.load
    topic_page.search_govuk("AbccdefghijkLmnopqrstuvwxyz")

    expect(search_page).to have_no_need_to_contact_radio
    expect(search_page).to have_no_self_serviced_radio

    expect(search_page).to have_need_to_contact_form

    search_page.send_correspondence(name,
                                    email,
                                    message)

    success_messages.each do |success_message|
      expect(page).to have_content(success_message)
    end

    expect(Correspondence.count).to eq 1
    expect(Correspondence.last).to have_attributes(
      name:,
      email:,
      message:,
      topic: "AbccdefghijkLmnopqrstuvwxyz",
    )
    expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.with("ConfirmationMailer", "new_confirmation", "deliver_now", args: anything).at_least(:once)
  end

  scenario "Message character count updates when text is entered", :js do
    max_length = Settings.correspondence_message_max_length
    input_within_maxlength = "a" * rand(1..max_length)
    input_over_maxlength = "a" * rand(max_length + 1..max_length + 1000)

    topic_page.load
    topic_page.search_govuk(topic_with_results)

    expect(search_page).to be_loaded

    search_page.need_to_contact_radio.click

    search_page.wait_until_need_to_contact_form_visible

    expect(search_page.need_to_contact_form).to have_text("By using this service you agree to these")

    expect(search_page.need_to_contact_form).to have_text(". Please read them carefully.")

    expect(search_page).to have_link("terms and conditions", href: "/correspondence/t_and_c")

    expect(search_page.need_to_contact_form.counter.text).to eq "You have #{max_length.to_fs(:delimited)} characters remaining"

    search_page.need_to_contact_form.message.set input_within_maxlength

    expect(search_page.need_to_contact_form.counter.text).to eq "You have #{(max_length - input_within_maxlength.length).to_fs(:delimited)} characters remaining"

    search_page.need_to_contact_form.message.set input_over_maxlength

    expect(search_page.need_to_contact_form.counter.text).to eq "You have #{(input_over_maxlength.length - max_length).to_fs(:delimited)} characters too many"
  end

  scenario "message character count shows correct count after failed submission with over-limit text", :js do
    max_length = Settings.correspondence_message_max_length
    input_over_maxlength = "a" * rand(max_length + 1..max_length + 1000)

    topic_page.load
    topic_page.search_govuk(topic_with_results)

    expect(search_page).to be_loaded

    search_page.need_to_contact_radio.click

    search_page.wait_until_need_to_contact_form_visible

    expect(search_page.need_to_contact_form.counter.text).to eq "You have #{max_length.to_fs(:delimited)} characters remaining"

    search_page.send_correspondence(name,
                                    email,
                                    input_over_maxlength)

    search_page.wait_until_need_to_contact_form_visible

    expect(search_page.need_to_contact_form.counter.text).to eq "You have #{(input_over_maxlength.length - max_length).to_fs(:delimited)} characters too many"
  end
end
