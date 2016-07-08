require 'rails_helper'

feature 'A member of the public makes an FOI request' do

  background do 
    @name = Faker::Name.name
    @email = Faker::Internet.email
    @text = Faker::Lorem.paragraphs[1]
  end

  scenario 'Using valid inputs' do
    visit 'correspondence/new'
    fill_in 'Name', with: @name
    fill_in 'Email', with: @email
    fill_in 'Email confirmation', with: @email
    page.find(:select, text: 'Freedom').select('Freedom of Information Request')
    page.find(:select, text: 'Prisons').select('Prisons')
    fill_in 'Message', with: @text
    click_button 'Send'
    expect(page).to have_content('Thank you')
  end

  #scenario 'Using invalid inputs' do
    # TO DO
  #end

end
