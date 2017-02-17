require 'rails_helper'

feature 'Submit a general enquiry' do
  given(:start_page){ StartPage.new }

  given(:name)            { Faker::Name.name                   }
  given(:email)           { Faker::Internet.email              }
  given(:message)         { Faker::Lorem.paragraphs[1]         }
  given(:topic_input)     { Faker::Hipster.sentence(word_count=20) } # rubocop:disable UselessAssignment
  given(:topic_stored)    { topic_input[0..59]                 }
  given(:error_messages) do
    [
      "What is your query about? Please tell us what your query is about.",
      "Full name can't be blank",
      "Email can't be blank",
      "Confirm email can't be blank",
      "What do you want to tell the Ministry of Justice? can't be blank"
    ]
  end
  given(:success_messages) do
    [
      "Your message has been sent",
      "We've sent a confirmation email to #{email}",
      "We will review your message.",
      "If we're able to respond, we'll do so within 1 month.",
      "We'll send any response to the above email."
    ]
  end

  scenario 'User should start at the service "Start page"' do
    start_page.load

    expect(start_page).to have_sidebar
    expect(start_page.sidebar).to have_find_a_court
    expect(start_page.sidebar).to have_find_a_prison
    expect(start_page.sidebar).to have_visit_a_prison
    expect(start_page.sidebar.other_services.size).to eq 3

    start_page.start_button.click
    expect(page.current_path).to eq new_correspondence_path
  end

  scenario 'Using valid inputs' do

    visit 'correspondence/new'
    fill_in 'correspondence[name]',               with: name
    fill_in 'correspondence[email]',              with: email
    fill_in 'correspondence[message]',            with: message
    fill_in 'correspondence[email_confirmation]', with: email
    fill_in 'correspondence[topic]',              with: topic_input
    click_button 'Send'

    success_messages.each do
      |success_message| expect(page).to have_content(success_message)
    end

    expect(Correspondence.count).to eq 1
    expect(Correspondence.last).to have_attributes(
      name: name,
      email: email,
      message: message,
      topic: topic_stored
    )

    expect(EmailCorrespondenceJob).to have_been_enqueued.with(Correspondence.last)
    expect(EmailConfirmationJob).to have_been_enqueued.with(Correspondence.last)

    expect(page).to have_link(
      'Return to the Ministry of Justice homepage',
      href: 'https://www.gov.uk/government/organisations/ministry-of-justice'
    )
  end

  scenario 'Without a topic, name, email address, confirm email or message' do
    visit 'correspondence/new'
    click_button 'Send'
    error_messages.each do
      |error_message| expect(page).to have_content(error_message)
    end
  end

  scenario 'With mismatching email and confirm email inputs' do
    visit 'correspondence/new'
    fill_in 'correspondence[name]',               with: name
    fill_in 'correspondence[email]',              with: email
    fill_in 'correspondence[message]',            with: message
    fill_in 'correspondence[email_confirmation]', with: 'mismatch@email.com'
    fill_in 'correspondence[topic]',              with: topic_input
    click_button 'Send'
    expect(page).to have_content("Confirm email doesn't match Email")
  end

  scenario 'and refreshing the page, does not cause a routing error' do
    visit 'correspondence/new'
    click_button 'Send'
    expect{ visit current_path }.not_to raise_error
  end
end

