require 'rails_helper'

feature 'A member of the public makes a request' do

  background do 
    @name = Faker::Name.name
    @email = Faker::Internet.email
    @text = Faker::Lorem.paragraphs[1]
    @error_messages = ["Name can't be blank", "Email can't be blank", "Message can't be blank"]
  end

  scenario 'Using valid inputs' do
    visit 'correspondence/new'
    fill_in 'Name', with: @name
    fill_in 'correspondence[email]', with: @email
    fill_in 'Email confirmation', with: @email
    page.find(:select, text: 'Freedom').select('Freedom of information request')
    page.find(:select, text: 'Prisons').select('Prisons')
    fill_in 'Message', with: @text
    click_button 'Send'
    expect(page).to have_content('Thank you')
    click_link 'Finish'
    expect(page.current_path).to eq root_path
  end

  scenario 'Without supplying a name, email address, email confirmation or message' do
    visit 'correspondence/new'
    page.find(:select, text: 'Freedom').select('Freedom of information request')
    page.find(:select, text: 'Prisons').select('Prisons')
    click_button 'Send'
    @error_messages.each { |error_message| expect(page).to have_content(error_message) }
  end

  scenario 'and then refreshing the page, does not cause a routing error' do
    visit 'correspondence/new'
    click_button 'Send'
    expect{ visit current_path }.not_to raise_error
  end

end
