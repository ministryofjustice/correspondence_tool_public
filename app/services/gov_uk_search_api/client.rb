require 'curb'

module GovUkSearchApi
  class Client

    SEARCH_API_URL = 'https://www.gov.uk/api/search.json'

    def initialize(query)
      @raw_query = query
      @query = URI.encode(query)
    end

    def search
      curl_response = Curl.get(SEARCH_API_URL + '?q=' + @query)
      Response.new(@raw_query, curl_response)
    end

  end
end
