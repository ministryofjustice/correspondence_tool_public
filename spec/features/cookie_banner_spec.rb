require "rails_helper"

RSpec.feature "CookieBanner", type: :feature do
  before do
    visit "/"
  end

  scenario "User sees the cookie banner on the homepage" do
    expect(page).to have_content("We use some essential cookies to make this service work.")
  end

  scenario "User accepts analytics cookies" do
    expect(page).to have_content("We use some essential cookies to make this service work.")
    click_link "Accept analytics cookies"
    expect(page).not_to have_content("We use some essential cookies to make this service work.")
    expect(page).to have_content("You've accepted analytics cookies.")
  end

  scenario "User rejects analytics cookies" do
    expect(page).to have_content("We use some essential cookies to make this service work.")
    click_link "Reject analytics cookies"
    expect(page).not_to have_content("We use some essential cookies to make this service work.")
    expect(page).to have_content("You've rejected analytics cookies. You can change your cookie settings at any time.")
  end

  scenario "User accepts and hides cookie banner mid service", :js do
    expect(page).to have_content("We use some essential cookies to make this service work.")
    click_link "Start now"
    fill_in "correspondence-topic-field", with: "Abcde"
    click_button "Continue"
    click_link "Accept analytics cookies"
    click_link "Hide this message"
    expect(page).not_to have_content("Cookies on Contact the Ministry of Justice")
    expect(page).to have_content("You're contacting the Ministry of Justice about")
  end
end
