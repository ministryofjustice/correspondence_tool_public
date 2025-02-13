module AnalyticsHelper
  def analytics_consent_cookie
    cookies[ConsentCookie::COOKIE_NAME]
  end

  def analytics_allowed?
    analytics_consent_cookie == ConsentCookie::ACCEPT
  end
end
