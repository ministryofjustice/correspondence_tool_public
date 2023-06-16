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
    end
  end
end
