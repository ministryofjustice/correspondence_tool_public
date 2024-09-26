require "rails_helper"

describe "correspondence/t_and_c" do
  it "displays the t and c page" do
    render

    expect(rendered).to have_text("Terms and conditions")
    expect(rendered).to have_text("Privacy policy")
  end
end
