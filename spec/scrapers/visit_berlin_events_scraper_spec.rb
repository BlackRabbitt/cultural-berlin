# frozen_string_literal: true

require 'rails_helper'
require 'support/scraper_helper'

RSpec.describe VisitBerlinEventsScraper do
  include ScraperHelper

  let(:scraper) { described_class.new('https://www.visitberlin.de/en/event-calendar-berlin') }

  before { allow(scraper).to receive(:html_document) { |uri| test_response(uri) } }

  it { expect(scraper.event_containers.size).to be(21) }
  it { expect(scraper.start_url.to_s).to eql('https://www.visitberlin.de/en/event-calendar-berlin') }
  it { expect(scraper.next_page_params).to eql({ query: 'page=1' }) }

  describe 'perform' do
    context 'with single page' do
      before { scraper.perform }

      it { expect(scraper.events.count).to be(21) }
      it { expect(scraper.pages.map(&:to_s)).to eql(['https://www.visitberlin.de/en/event-calendar-berlin']) }
    end

    context 'with all pages, no limit' do
      before { scraper.perform(paginate: true) }

      it { expect(scraper.events.count).to be(35) }

      it do
        expect(scraper.pages.map(&:to_s)).to eql(['https://www.visitberlin.de/en/event-calendar-berlin',
                                                  'https://www.visitberlin.de/en/event-calendar-berlin?page=1'])
      end
    end
  end

  describe 'parse_response' do
    describe 'without block' do
      before { scraper.parse_response }

      it { expect(scraper.events.count).to be(21) }

      describe 'first event' do
        subject(:event) { scraper.events.first }

        it { expect(event[:event_id]).to eql('/en/event/adventure-buddy-bear-hunt-across-berlin') }
        it { expect(event[:event_url]).to eql('https://www.visitberlin.de/en/event/adventure-buddy-bear-hunt-across-berlin') } # rubocop:disable Layout/LineLength
        it { expect(event[:title]).to eql('Adventure: Buddy Bear Hunt across Berlin') }
        it { expect(event[:description]).to eql("The Buddy Bears Berlin have become an integral part of Berlin's cityscape. There are now around 500 bears that stand as a friendly, colorful symbol of tolerance in the streets (and as a landmark) of Berlin. They are unofficial ambassadors of Berlin.") } # rubocop:disable Layout/LineLength
        it { expect(event[:category]).to eql('Walking Tour') }
        it { expect(event[:image_url]).to eql('https://www.visitberlin.de/system/files/styles/visitberlin_teaser_search_visitberlin_desktop_1x/private/event_images/vb-2-4a59b516-989f-4489-a502-604310293ce9.jpg.webp?h=a0982569&itok=VqJQrmYi') } # rubocop:disable Layout/LineLength
        it { expect(event[:event_from]).to eql('03 Feb, 2022'.to_date) }
        it { expect(event[:event_to]).to eql('31 Dec, 2022'.to_date) }
        it { expect(event[:event_time_from]).to eql('08:00 am'.to_time) }
        it { expect(event[:event_location]).to eql('Verschiedene Orte') }
        it { expect(event[:ticket_url]).to eql('https://www.visitberlin.de/de/kudamm56_berlin/?source=bde') }
      end
    end

    context 'with block provided' do
      let(:event_titles) { [] }

      before do
        scraper.parse_response { |evt| event_titles << evt[:title] }
      end

      it { expect(event_titles.size).to be(21) }
      it { expect(event_titles.first).to eql('Adventure: Buddy Bear Hunt across Berlin') }
    end
  end
end
