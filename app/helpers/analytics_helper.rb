module AnalyticsHelper
  def analytics_consent_cookie
    cookies[ConsentCookie::COOKIE_NAME]
  end

  def analytics_consent_accepted?
    analytics_consent_cookie == ConsentCookie::ACCEPT
  end
end
