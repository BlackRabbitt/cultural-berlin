# frozen_string_literal: true

require 'rails_helper'
require 'support/scraper_helper'

RSpec.describe ApplicationScraper do
  include ScraperHelper

  let(:url) { 'https://test.com' }
  let!(:scraper) { described_class.new(url) }

  before do
    allow(scraper).to receive(:open_page).and_return test_response(scraper.start_url)
  end

  it { expect(scraper.instance_variable_get(:@start_url)).to eql(URI.parse(url)) }
  it { expect(scraper.instance_variable_get(:@pages)).to eql([url]) }

  it 'parse and return nokogiri html response' do
    expect(scraper.response.css('h1').text).to eql('Hello, this is test html rendered for domain: https://test.com')
  end

  describe '.perform' do
    before do
      allow(scraper).to receive(:parse_response).and_return true
      allow(scraper).to receive(:next_page_params).and_return({ query: scraper.response.css('.next')&.text })
    end

    context 'with default parameters' do
      before { scraper.perform }

      it 'fetch first page only' do
        expect(scraper.pages).to eql(['https://test.com'])
      end
    end

    context 'with paginate parameters without limit' do
      before { scraper.perform(paginate: true) }

      it 'follows all paginated links' do
        expect(scraper.pages).to eql(['https://test.com', 'https://test.com?page=2'])
      end
    end

    context 'with paginate parameters with limit 1' do
      before { scraper.perform(paginate: true, page_limit: 1) }

      it 'fetch first page only' do
        expect(scraper.pages).to eql(['https://test.com'])
      end
    end

    context 'with paginate parameters with limit 2' do
      before { scraper.perform(paginate: true, page_limit: 2) }

      it 'follows paginated link until limit is reached' do
        expect(scraper.pages).to eql(['https://test.com', 'https://test.com?page=2'])
      end
    end
  end

  describe '.navigate' do
    it 'navigates to provided query path' do
      expect(scraper.navigate(query: 'page=2')).to eql('https://test.com?page=2')
    end

    it 'navigates to same page if no params' do
      expect(scraper.navigate).to eql('https://test.com')
    end
  end
end
