module AskTool
  module Pages
    module Application
      # def initialize
      #   @pages = {}
      # end

      def pages
        @pages ||= {}
      end

      def search_page
        pages[:search] ||= AskTool::Pages::Correspondence::SearchPage.new
      end

      def start_page
        pages[:start] ||= AskTool::Pages::Correspondence::StartPage.new
      end

      def topic_page
        pages[:topic] ||= AskTool::Pages::Correspondence::TopicPage.new
      end

      def confirmation_page
        pages[:confirmation] ||= AskTool::Pages::Correspondence::ConfirmationPage.new
      end

      def authenticate_page
        pages[:authenticate] ||= AskTool::Pages::Correspondence::AuthenticatePage.new
      end
    end
  end
end
