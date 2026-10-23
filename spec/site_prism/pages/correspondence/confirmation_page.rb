module AskTool
  module Pages
    module Correspondence
      class ConfirmationPage < SitePrism::Page
        set_url "/correspondence/confirmation/{uuid}"

        element :heading, "h1"
        element :uuid, ".uuid"
      end
    end
  end
end
