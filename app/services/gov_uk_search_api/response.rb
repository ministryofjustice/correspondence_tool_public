module GovUkSearchApi
  class Response

    attr_reader :query, :result_items, :response_code

    def initialize(query, curl_response)
      @query = query
      @curl_response = curl_response
      @response_code = @curl_response.response_code
      @result_items = JSON.parse(@curl_response.body_str)['results'].map do |result|
        ResultItem.new(result)
      end
    end

    def num_items
      @result_items.size
    end

  end
end