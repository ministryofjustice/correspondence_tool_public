module AnalyticsHelper
  def analytics_consent_cookie
    cookies[ConsentCookie::COOKIE_NAME]
  end
end
