# frozen_string_literal: true

require 'rails_helper'
require 'support/scraper_helper'

RSpec.describe ApplicationScraper do
  include ScraperHelper

  let(:url) { 'https://test.com' }
  let(:scraper) { described_class.new(url) }

  before { allow(scraper).to receive(:html_document) { |uri| test_response(uri) } }

  it { expect(scraper.instance_variable_get(:@start_url)).to eql(URI.parse(url)) }
  it { expect(scraper.instance_variable_get(:@pages)).to eql([]) }

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
        expect(scraper.pages.map(&:to_s)).to eql(['https://test.com'])
      end
    end

    context 'with paginate parameters with limit 1' do
      before do
        scraper.perform(paginate: true, page_limit: 1)
      end

      it 'fetch first page only' do
        expect(scraper.pages.map(&:to_s)).to eql(['https://test.com'])
      end
    end

    context 'with paginate parameters without limit' do
      before do
        scraper.perform(paginate: true)
      end

      it 'follows all paginated links' do
        expect(scraper.pages.map(&:to_s)).to eql(['https://test.com', 'https://test.com?page=2'])
      end
    end

    context 'with paginate parameters with limit 2' do
      before do
        scraper.perform(paginate: true, page_limit: 2)
      end

      it 'follows paginated link until limit is reached' do
        expect(scraper.pages.map(&:to_s)).to eql(['https://test.com', 'https://test.com?page=2'])
      end
    end
  end

  describe '.navigate' do
    it 'navigates to same page if no params' do
      expect(scraper.navigate.to_s).to eql('https://test.com')
    end

    it 'navigates to provided query' do
      expect(scraper.navigate(query: 'page=2').to_s).to eql('https://test.com?page=2')
    end

    it 'navigates to provided path' do
      expect(scraper.navigate(path: '/en/programme/2022/06/all').to_s).to eql('https://test.com/en/programme/2022/06/all')
    end

    it 'navigates to provided path and query' do
      expect(scraper.navigate(query: 'page=2', path: '/en/programme/2022/06/all').to_s).to eql('https://test.com/en/programme/2022/06/all?page=2')
    end
  end
end
