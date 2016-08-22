require 'rails_helper'

feature 'A member of the public finds the the answer or is signposted to the correct service' do

  background do
    @name = Faker::Name.name
    @email = Faker::Internet.email
    @text = Faker::Lorem.paragraphs[1]
    @error_messages = ["Name can't be blank", "Email can't be blank", "Message can't be blank"]
  end

  scenario 'member of the public wants to find out about courts' do
    visit root_path
    click_link 'Start now'
    expect(page).to have_content 'What is your question about?'
    choose 'Courts and tribunals'
    click_link 'Continue'
    expect(page).to have_content 'About the Ministry of Justice'
    fill_in 'correspondence[message]', with: @text
    click_link 'Continue'
    expect(page).to have_content 'Your details'
    fill_in 'Name', with: @name
    click_link 'Continue'
    fill_in 'correspondence[email]', with: @email
    fill_in 'Email confirmation', with: @email
    click_link 'Send'
    expect(page).to have_content('Thank you')
  end

  scenario 'member of the public wants to find out about prisons' do
    visit root_path
    click_link 'Start now'
    expect(page).to have_content 'What is your question about?'
    choose 'Courts and tribunals'
    click_link 'Continue'
    expect(page).to have_content 'About the Ministry of Justice'
    fill_in 'correspondence[message]', with: @text
    click_link 'Continue'
    expect(page).to have_content 'Your details'
    fill_in 'Name', with: @name
    click_link 'Continue'
    fill_in 'correspondence[email]', with: @email
    fill_in 'Email confirmation', with: @email
    click_link 'Send'
    expect(page).to have_content('Thank you')
  end

  scenario 'member of the public wants to find out about something else' do
    visit root_path
    click_link 'Start now'
    expect(page).to have_content 'What is your question about?'
    choose 'something else'
    click_link 'Continue'
    expect(page).to have_content 'About the Ministry of Justice'
    fill_in 'correspondence[message]', with: @text
    click_link 'Continue'
    expect(page).to have_content 'Your details'
    fill_in 'Name', with: @name
    click_link 'Continue'
    fill_in 'correspondence[email]', with: @email
    fill_in 'Email confirmation', with: @email
    click_link 'Send'
    expect(page).to have_content('Thank you')
  end
end
