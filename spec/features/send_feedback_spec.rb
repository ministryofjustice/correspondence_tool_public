require 'rails_helper'

feature 'Submit service feedback' do

    given(:rating)          { Settings.service_feedback.sample.humanize }
    given(:comment)         { Faker::Lorem.paragraphs[1] }
    given(:error_messages) do
      [
        "Rating please select one option"
      ]
    end

  scenario 'Using valid inputs' do
    visit 'feedback/new'
    choose rating
    fill_in 'feedback[comment]', with: comment
    click_button 'Send'
    expect(current_path).to eq correspondence_path
    expect(page).to have_content('Feedback submitted')
  end

  scenario 'Without a rating' do
    visit 'feedback/new'
    click_button 'Send'
    error_messages.each do
      |error_message| expect(page).to have_content(error_message)
    end
  end

end
