require File.dirname(__FILE__) + '/../../rails_helper'

module GovUkSearchApi
  describe Response do

    let(:json_body) do
      {
        'results' => [
          {
            'item_1_key_1' => 'item_1_value_1'
          },
          {
            'item_2_key_1' => 'item_2_value_1'
          },
        ]
      }.to_json
    end

    let(:raw_response) { double Curl::Easy, response_code: 200, body_str: json_body }
    let(:query) { 'Ministry of Justice' }
    let(:response) { Response.new(query,  raw_response) }

    describe '#response_code' do
      it 'returns the response code from the EasyCurl response' do
        expect(response.response_code).to eq 200
      end
    end

    describe '#query' do
      it 'returns the raw query' do
        expect(response.query).to eq 'Ministry of Justice'
      end
    end

    context 'result_items' do

      before(:each) do
        @ri_1 = double 'Result item 1'
        @ri_2 = double 'Result item 2'
        expect(ResultItem).to receive(:new).with('item_1_key_1' => 'item_1_value_1').and_return(@ri_1)
        expect(ResultItem).to receive(:new).with('item_2_key_1' => 'item_2_value_1').and_return(@ri_2)
      end

      describe '#result_items' do
        it 'returns an array of result items created from the json response' do
          expect(response.result_items).to eq [@ri_1, @ri_2]
        end
      end

      describe '#num_items' do
        it 'returns a count of the result items in the response' do
          expect(response.num_items).to eq 2
        end
      end
    end

  end
end