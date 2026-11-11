require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "page title displays error status" do
    let(:correspondence) { build(:correspondence, :authenticated) }

    it "returns page with error title when there are errors" do
      binding.irb
      expect(helper.govuk_error_summary(correspondence.page)).to include("Error:")
    end
  end
end
