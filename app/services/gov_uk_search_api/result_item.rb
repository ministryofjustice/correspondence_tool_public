module GovUkSearchApi

  class ResultItem

    def initialize(item_hash)
      @item_hash = item_hash
    end

    def title
      @item_hash['title']
    end

    def description
      @item_hash['description']
    end

    def link
      full_url?(@item_hash['link']) ? @item_hash['link'] :  'https://www.gov.uk' + @item_hash['link']
    end

    def meta_data
      "#{display_type_and_date} #{organisation_acronyms.join(', ')}".squeeze(' ').strip
    end

    private

    def full_url?(link)
      !!(link =~ /\Ahttp/)
    end

    def display_type_and_date
      if display_type == 'News story'
        "News story #{publication_date}"
      else
        display_type
      end
    end

    def display_type
      @item_hash['display_type']
    end

    def publication_date
      if @item_hash.key?('public_timestamp')
        Date.parse(@item_hash['public_timestamp']).strftime('%-d %b %Y')
      end
    end

    def organisation_acronyms
      @item_hash['organisations'].map { |org| org['acronym'] }
    end
  end
end