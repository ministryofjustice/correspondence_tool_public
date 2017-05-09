require 'rails_helper'

describe 'correspondence/confirmation.html.slim' do

  it 'displays the creators email address' do
    item = create :correspondence, email: 'person@example.com'
    assign(:correspondence, item)

    render

    expect(rendered).to have_text('One more step...')
    expect(rendered).to have_text("We've sent an email to person@example.com")
  end
end
