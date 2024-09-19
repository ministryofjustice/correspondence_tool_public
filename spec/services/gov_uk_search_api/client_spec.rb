require "#{File.dirname(__FILE__)}/../../rails_helper"

module GovUkSearchApi
  RSpec.describe Client, type: :model do
    let(:query) { "Ministry of Justice" }
    let(:filtered_query) { "Ministry Justice" }

    describe "#search" do
      let(:url_query) { "https://www.gov.uk/api/search.json?count=3&q=#{ERB::Util.url_encode(filtered_query)}" }

      context "when successful call to API" do
        it "calls httparty with the URI encoded query and the httparty response and returns a Response object" do
          httparty = instance_double HTTParty
          response = instance_double Response
          allow(HTTParty).to receive(:get).with(url_query).and_return(httparty)
          allow(Response).to receive(:new).with(query, httparty).and_return(response)

          actual_response = described_class.new(query).search
          expect(actual_response).to eq response
        end
      end

      context "when unsuccessful_call to API" do
        it "instantiates an empty result with error details" do
          expect(HTTParty).to receive(:get).with(url_query).and_raise(HTTParty::ResponseError, "No data")
          response = described_class.new(query).search
          expect(response).to be_instance_of(Response)
          expect(response.num_items).to eq 0
          expect(response.error).to eq({
            "error" => {
              "event" => "query_search",
              "search_term" => "Ministry of Justice",
              "error_class" => "HTTParty::ResponseError",
              "message" => "No data",
            },
          })
        end
      end
    end

    describe "#more_results_url" do
      it "returns the html gov uk query url with encoded query" do
        client = described_class.new(query)
        expect(client.more_results_url).to eq "https://www.gov.uk/search?q=Ministry%20Justice"
      end
    end
  end
end
