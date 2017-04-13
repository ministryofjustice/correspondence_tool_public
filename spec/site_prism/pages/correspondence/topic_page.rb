module AskTool
  module Pages
    module Correspondence
      class TopicPage < SitePrism::Page
        set_url '/correspondence/topic'

        element :topic_field, '#correspondence_topic'
        element :continue_button, 'input[type="submit"][value="Continue"]'

        def search_govuk(topic)
          topic_field.set topic
          continue_button.click
        end
      end
    end
  end
end

