require "rails_helper"

feature "Full correspondence journey regression" do
  given(:name)               { Faker::Name.name }
  # Fixed, rather than Faker-generated: this is rendered on the confirmation
  # page under screenshot comparison, and a random length/value would shift
  # text wrapping and cause false-positive visual regression failures.
  given(:email)              { "regression.test@example.com" }
  given(:message)            { Faker::Lorem.paragraphs[1] }
  given(:topic_with_results) { "Visiting a prison" }

  scenario "User starts, searches, submits a message and authenticates it via the emailed link", :js do
    start_page.load
    expect(start_page).to be_displayed
    expect(page).to match_screenshot("regression/start_page")

    start_page.start_button.click
    expect(topic_page).to be_displayed

    topic_page.search_govuk(topic_with_results)
    expect(search_page).to be_displayed
    expect(page).to match_screenshot("regression/search_page")

    search_page.need_to_contact_radio.click
    search_page.wait_until_need_to_contact_form_visible
    expect(page).to match_screenshot("regression/contact_form")

    search_page.send_correspondence(name, email, message)

    expect(confirmation_page).to be_displayed
    expect(page).to have_content("One more step...")
    expect(page).to have_content("We've sent an email to #{email}")
    expect(page).to match_screenshot("regression/confirmation_page")

    correspondence = Correspondence.last
    expect(correspondence).to have_attributes(
      name:,
      email:,
      message:,
      topic: topic_with_results,
    )
    expect(correspondence).not_to be_authenticated

    visit correspondence_authentication_path(correspondence.uuid)

    expect(authenticate_page).to be_displayed
    expect(page).to have_content("Your message has been sent")
    expect(page).to have_content("We will review your message and reply to your email address.")
    expect(page).to have_link("Return to the Ministry of Justice homepage")
    expect(page).to match_screenshot("regression/authenticate_page")

    expect(correspondence.reload).to be_authenticated
  end
end
