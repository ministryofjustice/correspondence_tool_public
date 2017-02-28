require File.dirname(__FILE__) + '/../../rails_helper'

module GovUkSearchApi

  describe ResultItem do

    describe '#title' do
      it 'extracts the title from the hash' do
        item = ResultItem.new(standard_item)
        expect(item.title).to eq 'Title of result item'
      end
    end

    describe '#description' do
      it 'extracts the description from the hash' do
        item = ResultItem.new(standard_item)
        expect(item.description).to eq 'This is a description paragraph'
      end
    end

    describe '#link' do
      it 'extracts the link from the hash' do
        item = ResultItem.new(standard_item)
        expect(item.link).to eq 'https://www.gov.uk/organisations/example-ministry'
      end
    end

    describe '#meta_data' do
      context 'no display type' do
        it 'returns just the organisation acronyms' do
          item = ResultItem.new(standard_item)
          expect(item.meta_data).to eq 'MOJ, HMCTS'
        end
      end

      context 'display type without public timestamp' do
        it 'returns the display type and organisation acronyms' do
          item = ResultItem.new(correspondence_item)
          expect(item.meta_data).to eq 'Correspondence MOJ, HMCTS'
        end
      end

      context 'display type of news story' do
        it 'returns News Story with publication date and organisation acronyms' do
          item = ResultItem.new(news_story_item)
          expect(item.meta_data).to eq 'News story 3 Feb 2017 MOJ, HMCTS'
        end
      end
    end

    def standard_item
      {
        'title' => 'Title of result item',
        'description' => 'This is a description paragraph',
        'link' => '/organisations/example-ministry',
        'organisations' => [
          {
            'title' => 'Ministry of Justice',
            'acronym' => 'MOJ'
          },
          {
            'title' => 'HM Courts & Tribunals Service',
            'acronym' => 'HMCTS'
          }
        ]

      }
    end

    def correspondence_item
      {
        'title' => 'Title of result item',
        'description' => 'This is a description paragraph',
        'link' => '/organisations/example-ministry',
        'display_type' => 'Correspondence',
        'organisations' => [
          {
            'title' => 'Ministry of Justice',
            'acronym' => 'MOJ'
          },
          {
            'title' => 'HM Courts & Tribunals Service',
            'acronym' => 'HMCTS'
          }
        ]
      }
    end

    def news_story_item
      {
        'title' => 'Title of result item',
        'description' => 'This is a description paragraph',
        'link' => '/organisations/example-ministry',
        'display_type' => 'News story',
        'public_timestamp' => '2017-02-03T16:53:00.000+00:00',
        'organisations' => [
          {
            'title' => 'Ministry of Justice',
            'acronym' => 'MOJ'
          },
          {
            'title' => 'HM Courts & Tribunals Service',
            'acronym' => 'HMCTS'
          }
        ]
      }
    end
  end
end
