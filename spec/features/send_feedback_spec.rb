require 'rails_helper'

feature 'Submit service feedback' do

    given(:rating)          { Settings.service_feedback.sample.humanize }
    given(:comment)         { Faker::Lorem.paragraphs[1] }

  scenario 'Using valid inputs' do
    visit 'feedback/new'
    choose rating
    fill_in 'feedback[comment]', with: comment
    click_button 'Send'
    expect(current_path).to eq '/feedback'
    expect(page).to have_content('Your feedback has been sent')
  end

  scenario 'Without a rating' do
    visit 'feedback/new'
    click_button 'Send'
    expect(page).to have_content("Rating please select one option")
  end

end
