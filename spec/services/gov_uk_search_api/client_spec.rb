require File.dirname(__FILE__) + '/../../rails_helper'

module GovUkSearchApi

  RSpec.describe Client, type: :model do
    describe '#search' do
      it 'calls Curl with the URI encoded query and the curl response and returns a Response object' do
        query = 'Ministry of Justice'
        url_query = "https://www.gov.uk/api/search.json?q=#{URI.encode(query)}"
        curl_easy = double Curl::Easy
        response = double Response
        expect(Curl).to receive(:get).with(url_query).and_return(curl_easy)
        expect(Response).to receive(:new).with(query, curl_easy).and_return(response)

        actual_response = Client.new(query).search
        expect(actual_response).to eq response
      end

    end
  end
end
