require 'curb'

module GovUkSearchApi
  class Client

   NUM_RESULTS = 3

    def initialize(query)
      @raw_query = query
      @query = URI.encode(query)
    end

    def search
      CtpCustomLogger.info({event: 'query_search', search_term: @raw_query})
      begin
        curl_response = Curl.get(json_query_url)
        Response.new(@raw_query, curl_response)
      rescue => err
        Rails.logger.error(event: 'query_search', search_term: @raw_query, error_class: err.class, message: err.message)
        Response.new(@raw_query, {error: {event: 'query_search', search_term: @raw_query, error_class: err.class.to_s, message: err.message}}.to_json)
      end
    end

   def html_query_url
     "#{Settings.gov_uk_search_url}?q=#{@query}"
   end

    private

    def json_query_url
      "#{Settings.gov_uk_search_api_url}?count=#{NUM_RESULTS}&q=#{@query}"
    end
  end
end
