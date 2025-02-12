class CookiesController < ApplicationController
  def update
    consent = params[:consent].presence_in([ConsentCookie::ACCEPT, ConsentCookie::REJECT])

    if consent.nil?
      head :not_found and return
    end

    cookies[ConsentCookie::COOKIE_NAME] = {
      expires: ConsentCookie::EXPIRATION,
      value: consent,
    }

    redirect_back fallback_location: root_path, flash: { cookies_consent_updated: consent }
  end
end
