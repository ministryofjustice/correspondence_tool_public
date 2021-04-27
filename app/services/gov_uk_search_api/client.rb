require 'curb'

module GovUkSearchApi
  class Client

   NUM_RESULTS = 3

    def initialize(query)
      @original_query = query

      filter = Stopwords::Snowball::Filter.new "en"
      filtered_words = filter.filter(@original_query.split)
      @filtered_query = ERB::Util.url_encode(filtered_words.join(' '))
    end

    def search
      CtpCustomLogger.info({event: 'query_search', search_term: @original_query})
      begin
        curl_response = Curl.get(json_query_url)
        Response.new(@original_query, curl_response)
      rescue => err
        Rails.logger.error(event: 'query_search', search_term: @original_query, error_class: err.class, message: err.message)
        Response.new(@original_query, {error: {event: 'query_search', search_term: @original_query, error_class: err.class.to_s, message: err.message}}.to_json)
      end
    end

   def more_results_url
     "#{Settings.gov_uk_search_url}?q=#{@filtered_query}"
   end

    private

    def json_query_url
      "#{Settings.gov_uk_search_api_url}?count=#{NUM_RESULTS}&q=#{@filtered_query}"
    end
  end
end
