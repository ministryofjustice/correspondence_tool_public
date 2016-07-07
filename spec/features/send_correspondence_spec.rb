require 'rails_helper'

feature 'A member of the public makes an FOI request' do

  beackground do 
    @name = Faker::Name.name
    @email = Faker::Internet.email
    @text = Faker::Lorem.paragraphs(1)
  end

  scenario 'Using valid inputs' do
    visit 'correspondence/new'
    fill_in 'Name', with: @name
    fill_in 'Email', with: @email
    fill_in 'Email confirmation', with: @email
    select 'Freedom of Information Request', from: "type_select"
    select 'Prisons', from: "subject_select"
    fill_in 'Message', with: @text
    click_button 'Send'
    expect(page).to have_content('Thank you')
  end

  #scenario 'Using invalid inputs' do
    # TO DO
  #end

end
