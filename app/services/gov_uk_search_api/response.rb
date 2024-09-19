module GovUkSearchApi
  class Response
    attr_reader :query, :result_items, :response_code, :error

    def initialize(query, response_or_error_hash)
      @query = query
      if response_or_error_hash.class == HTTParty::Response # rubocop:disable Style/ClassEqualityComparison
        populate_from_response(response_or_error_hash)
      else
        populate_from_error_hash(response_or_error_hash)
      end
    end

    def num_items
      @result_items.size
    end

  private

    def populate_from_response(response)
      @response = response
      @response_code = response.code
      @result_items = JSON.parse(@response.body)["results"].map do |result|
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
