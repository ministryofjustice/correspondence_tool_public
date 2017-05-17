require 'rails_helper'

feature 'Submit a general enquiry' do
  #
  # before do
  #   @app ||= AskTool::Pages::Application.new
  # end


  given(:name)               { Faker::Name.name                   }
  given(:email)              { Faker::Internet.email              }
  given(:message)            { Faker::Lorem.paragraphs[1]         }
  given(:topic_with_results) { 'Visiting a prison'}

  given(:topic_error) {
   "What are you contacting the Ministry of Justice about? can't be blank"
  }

  given(:error_messages) do
    [
      "Full name can't be blank",
      "Email can't be blank",
      "Your message can't be blank"
    ]
  end

  given(:success_messages) do
    [
      "One more step...",
      "We've sent an email to #{email}",
      "Go to your inbox and click the link in the email.",
      "You must click the link in your email to send your message to the Ministry of Justice.",
      "This is to check that your email address is valid."
    ]
  end

  scenario 'User should start at the service "Start page"' do
    start_page.load
    expect(start_page.title).to eq "Start - Contact the Ministry of Justice\n"

    expect(start_page).to have_sidebar
    expect(start_page.sidebar).to have_find_a_court
    expect(start_page.sidebar).to have_find_a_prison
    expect(start_page.sidebar).to have_visit_a_prison
    expect(start_page.sidebar.other_services.size).to eq 3

    start_page.start_button.click
    expect(topic_page).to be_displayed
    expect(topic_page.title).to eq "Topic search - Contact the Ministry of Justice\n"
  end

  scenario 'self-service - searching govuk service' do
    topic_page.load
    expect(topic_page.title).to eq "Topic search - Contact the Ministry of Justice\n"
    topic_page.search_govuk(topic_with_results)

    expect(search_page).to be_displayed
    expect(search_page.title).to eq "Contact form - Contact the Ministry of Justice\n"
    expect(search_page.self_service.size).to eq 4
    expect(search_page.self_service_ga_events.size).to eq 4
  end

  scenario 'Using valid inputs', js: true do
    topic_page.load
    expect(topic_page.title).to eq "Topic search - Contact the Ministry of Justice"
    topic_page.search_govuk(topic_with_results)

    expect(search_page).to be_displayed
    expect(search_page.title).to eq "Contact form - Contact the Ministry of Justice"

    expect(search_page).to have_self_serviced_radio

    #If GOVUK API results helped the user
    search_page.self_serviced_radio.click
    search_page.wait_until_self_serviced_radio_copy_visible

    #If GOVUK API results did not help the user
    search_page.need_to_contact_radio.click
    search_page.wait_until_need_to_contact_form_visible


    search_page.send_correspondence(name,
                                    email,
                                    message)

    success_messages.each do
      |success_message| expect(page).to have_content(success_message)
    end

    expect(Correspondence.count).to eq 1
    expect(Correspondence.last).to have_attributes(
      name: name,
      email: email,
      message: message,
      topic: topic_with_results
    )
    expect(EmailConfirmationJob).to have_been_enqueued.with(Correspondence.last)
  end

  scenario 'Without a topic, name, email address, confirm email or message' do
    topic_page.load

    expect(topic_page.title).to eq "Topic search - Contact the Ministry of Justice\n"

    topic_page.search_govuk('')
    expect(topic_page.text).to have_content(topic_error)

    expect(search_page.title).to eq "Topic search - Contact the Ministry of Justice\n"

    topic_page.search_govuk(topic_with_results)

    expect(search_page.title).to eq "Contact form - Contact the Ministry of Justice\n"

    search_page.need_to_contact_radio.click

    search_page.wait_until_need_to_contact_form_visible

    click_button 'Send'

    error_messages.each do
      |error_message| expect(page).to have_content(error_message)
    end
  end

  scenario 'A topic which returns zero results' do
    topic_page.load
    topic_page.search_govuk('AbccdefghijkLmnopqrstuvwxyz')

    expect(search_page).to have_no_need_to_contact_radio
    expect(search_page).to have_no_self_serviced_radio

    expect(search_page).to have_need_to_contact_form

    search_page.send_correspondence(name,
                                    email,
                                    message)

    success_messages.each do
      |success_message| expect(page).to have_content(success_message)
    end

    expect(Correspondence.count).to eq 1
    expect(Correspondence.last).to have_attributes(
                                       name: name,
                                       email: email,
                                       message: message,
                                       topic: 'AbccdefghijkLmnopqrstuvwxyz'
                                   )
    expect(EmailConfirmationJob).to have_been_enqueued.with(Correspondence.last)
  end

  scenario 'message character count updates when text is entered', js: true  do

    input_within_maxlength = 'a' * rand(1..5000)
    input_over_maxlength = 'a' * rand(5001..6000)

    topic_page.load
    topic_page.search_govuk(topic_with_results)

    expect(search_page).to be_loaded

    search_page.need_to_contact_radio.click

    search_page.wait_until_need_to_contact_form_visible

    expect(search_page.need_to_contact_form.counter.text).to eq "5000"

    search_page.need_to_contact_form.message.set input_within_maxlength

    expect(search_page.need_to_contact_form.counter.text).to eq "#{ 5000 - input_within_maxlength.length}"

    search_page.need_to_contact_form.message.set input_over_maxlength

    expect(search_page.need_to_contact_form.counter.text).to eq "#{ 5000 - input_over_maxlength.length}"


  end


  scenario 'message character count shows correct count on page load', js:true do
    input_over_maxlength = 'a' * rand(5001..6000)

    topic_page.load
    topic_page.search_govuk(topic_with_results)

    expect(search_page).to be_loaded

    search_page.need_to_contact_radio.click

    search_page.wait_until_need_to_contact_form_visible

    expect(search_page.need_to_contact_form.counter.text).to eq "5000"

    search_page.send_correspondence(name,
                                    email,
                                    input_over_maxlength)

    search_page.wait_until_need_to_contact_form_visible

    expect(search_page.need_to_contact_form.counter.text).to eq "#{ 5000 - input_over_maxlength.length}"

  end
end

