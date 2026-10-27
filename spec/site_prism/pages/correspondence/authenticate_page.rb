module AskTool
  module Pages
    module Correspondence
      class AuthenticatePage < SitePrism::Page
        set_url "/correspondence/authenticate/{uuid}"

        element :panel, ".govuk-panel"
      end
    end
  end
end
