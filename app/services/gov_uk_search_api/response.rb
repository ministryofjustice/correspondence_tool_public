module GovUkSearchApi
  class Response

    attr_reader :query, :result_items, :response_code, :error

    def initialize(query, curl_response_or_error_hash)
      @query = query
      if curl_response_or_error_hash.class == Curl::Easy
        populate_from_curl_response(curl_response_or_error_hash)
      else
        populate_from_error_hash(curl_response_or_error_hash)
      end
    end

    def num_items
      @result_items.size
    end

    private

    def populate_from_curl_response(curl_response)
      @curl_response = curl_response
      @response_code = curl_response.response_code
      @result_items = JSON.parse(@curl_response.body_str)['results'].map do |result|
        ResultItem.new(result)
      end
      @error = nil
    end

    def populate_from_error_hash(error_hash)
      @curl_response = nil
      @response_code = nil
      @result_items = []
      @error = JSON.parse(error_hash)
    end



  end
end