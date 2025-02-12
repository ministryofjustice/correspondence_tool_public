require "rails_helper"

RSpec.describe CookiesController, type: :controller do
  describe "GET update" do
    context "when cookies are accepted" do
      it "sets consent to 'accept'" do
        get :update, params: { consent: "accept" }
        expect(cookies[:contact_moj_cookies_consent]).to eq "accept"
      end

      it "redirects to fallback path" do
        response = get :update, params: { consent: "accept" }
        expect(response).to redirect_to root_path
      end
    end

    context "when cookies are rejected" do
      it "sets consent to 'reject'" do
        get :update, params: { consent: "reject" }
        expect(cookies[:contact_moj_cookies_consent]).to eq "reject"
      end

      it "redirects to fallback path" do
        response = get :update, params: { consent: "reject" }
        expect(response).to redirect_to root_path
      end
    end

    context "when consent is invalid" do
      it "does not set the cookie" do
        get :update, params: { consent: "invalid" }
        expect(cookies[:contact_moj_cookies_consent]).to be_nil
      end
    end
  end
end
