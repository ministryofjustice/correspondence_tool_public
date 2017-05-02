require 'rails_helper'

feature 'Authenticate a correspondence item' do

  given(:frozen_time) { Time.new(2017, 4, 13, 14, 15, 16) }

  scenario 'User authenticates an unauthenticated correspondence item' do
    correspondence = create :correspondence
    Timecop.freeze frozen_time do
      visit "/correspondence/authenticate/#{correspondence.uuid}"
      expect(page).to have_content('We will review your message and reply to your email address')
      expect(page).to have_content('We aim to respond to you as soon as possible, but allow up to 4 weeks for complex cases or during busy periods.')
      expect(correspondence.reload.authenticated_at).to eq frozen_time
    end
  end

  scenario 'User authenticates an already authenticated correspondence item and gets the same confirmation page' do
    authentication_time = Time.new(2017, 3, 2, 0, 3, 28)
    correspondence = create :correspondence, authenticated_at: authentication_time
    visit "/correspondence/authenticate/#{correspondence.uuid}"
    expect(page).to have_content('We will review your message and reply to your email address')
    expect(page).to have_content('We aim to respond to you as soon as possible, but allow up to 4 weeks for complex cases or during busy periods.')
  end

  scenario 'User attempts to authenticate with invalid uuid' do
    visit "/correspondence/authenticate/abcd-efgh-23454"
    expect(page).to have_http_status(404)
  end
end
