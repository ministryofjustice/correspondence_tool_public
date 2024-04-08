require "#{File.dirname(__FILE__)}/../../rails_helper"

describe GovUkSearchApi::Response do
  context "when created from a Curl::Easy response" do
    let(:json_body) do
      {
        "results" => [
          {
            "item_1_key_1" => "item_1_value_1",
          },
          {
            "item_2_key_1" => "item_2_value_1",
          },
        ],
      }.to_json
    end

    let(:raw_response) { instance_double Curl::Easy, response_code: 200, body_str: json_body, class: Curl::Easy }
    let(:query) { "Ministry of Justice" }
    let(:response) { described_class.new(query, raw_response) }

    describe "#response_code" do
      it "returns the response code from the EasyCurl response" do
        expect(response.response_code).to eq 200
      end
    end

    describe "#query" do
      it "returns the raw query" do
        expect(response.query).to eq "Ministry of Justice"
      end
    end

    describe "result_items" do
      let(:ri_1) { "Result item 1" }
      let(:ri_2) { "Result item 2" }

      before do
        allow(GovUkSearchApi::ResultItem).to receive(:new).with({"item_1_key_1" => "item_1_value_1"}).and_return(ri_1)
        allow(GovUkSearchApi::ResultItem).to receive(:new).with({"item_2_key_1" => "item_2_value_1"}).and_return(ri_2)
      end

      describe "#result_items" do
        it "returns an array of result items created from the json response" do
          expect(response.result_items).to eq [ri_1, ri_2]
        end
      end

      describe "#num_items" do
        it "returns a count of the result items in the response" do
          expect(response.num_items).to eq 2
        end
      end
    end
  end

  context "when created from an error hash" do
    it "has an item count of zero" do
      response = described_class.new("My Query", error_hash)
      expect(response.num_items).to eq 0
    end

    def error_hash
      {
        "error" => {
          "event" => "query_search",
          "search_term" => "My Query",
          "error_class" => "Curl::Err::GotNothingError",
          "message" => "No data",
        },
      }.to_json
    end
  end
end
