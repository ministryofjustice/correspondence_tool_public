module AskTool
  module Pages
    module Correspondence
      class TopicPage < SitePrism::Page
        set_url "/correspondence/topic"

        element :topic_field, "#correspondence-topic-field"
        element :topic_field_error, "#correspondence-topic-field-error"
        element :continue_button, 'button[type="submit"]'

        def search_govuk(topic, field = topic_field)
          field.set topic
          continue_button.click
        end
      end
    end
  end
end
