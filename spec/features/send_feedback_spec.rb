require "rails_helper"

feature "Submit service feedback" do
  given(:ease_of_use)   { Settings.feedback_options.sample }
  given(:completeness)  { Settings.feedback_options.sample }
  given(:comment)       { Faker::Lorem.paragraphs[1] }

  scenario "Using valid inputs" do
    visit feedback_path
    choose "feedback_ease_of_use_#{ease_of_use}"
    choose "feedback_completeness_#{completeness}"
    fill_in "feedback[comment]", with: comment
    click_button "Send"

    expect(page).to have_current_path feedback_path, ignore_query: true
    expect(page).to have_content("Your feedback has been sent")

    feedback = Feedback.last

    expect(feedback.comment).to eq comment
    expect(feedback.ease_of_use).to eq ease_of_use
    expect(feedback.completeness).to eq completeness

    expect(page).to have_link(
      "Return to the Ministry of Justice homepage",
      href: "https://www.gov.uk/government/organisations/ministry-of-justice",
    )
  end

  scenario "Without a rating for ease of use or completeness" do
    visit feedback_path
    click_button "Send"
    expect(page).to have_content("This online service was easy to use please select one option")
    expect(page).to have_content("The online service enabled me to give all the relevant information please select one option")
  end
end
