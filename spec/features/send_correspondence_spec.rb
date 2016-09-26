require 'rails_helper'

feature 'Submit a general enquiry' do

    given(:name)            { Faker::Name.name }
    given(:email)           { Faker::Internet.email }
    given(:message)         { Faker::Lorem.paragraphs[1] }
    given(:error_messages) do
      [
        "Topic can't be blank",
        "Full name can't be blank",
        "Email can't be blank",
        "Confirm email can't be blank",
        "Message can't be blank"
      ]
    end

  scenario 'Using valid inputs' do
    visit 'correspondence/new'
    fill_in 'correspondence[name]',               with: name
    fill_in 'correspondence[email]',              with: email
    fill_in 'correspondence[message]',            with: message
    fill_in 'correspondence[email_confirmation]', with: email
    choose 'Prisons and probation'
    click_button 'Send'
    expect(page).to have_content('Your message has been sent')
    click_link 'Finish'
    expect(page.current_path).to eq root_path
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
    choose 'Prisons and probation'
    click_button 'Send'
    expect(page).to have_content("Confirm email doesn't match Email")
  end

  scenario 'and refreshing the page, does not cause a routing error' do
    visit 'correspondence/new'
    click_button 'Send'
    expect{ visit current_path }.not_to raise_error
  end

end
