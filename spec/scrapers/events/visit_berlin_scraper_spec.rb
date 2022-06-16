# frozen_string_literal: true

require 'rails_helper'
require 'support/scraper_helper'

RSpec.describe Events::VisitBerlinScraper do
  include ScraperHelper

  let!(:scraper) { described_class.new }

  before do
    allow(scraper).to receive(:open_page).and_return test_response(scraper.start_url)
  end

  it { expect(scraper.event_containers.size).to be(21) }
  it { expect(scraper.next_page_params).to eql({ query: 'page=1' }) }

  describe 'parse_response' do
    describe 'first_event' do
      before { scraper.parse_response }

      # rubocop:disable Layout/LineLength
      let(:expected_event) do
        {
          event_id: '/en/event/adventure-buddy-bear-hunt-across-berlin',
          event_url: '/en/event/adventure-buddy-bear-hunt-across-berlin',
          title: 'Adventure: Buddy Bear Hunt across Berlin',
          description: "The Buddy Bears Berlin have become an integral part of Berlin's cityscape. There are now around 500 bears that stand as a friendly, colorful symbol of tolerance in the streets (and as a landmark) of Berlin. They are unofficial ambassadors of Berlin.",
          category: 'Walking Tour',
          image_url: '/system/files/styles/visitberlin_teaser_search_visitberlin_desktop_1x/private/event_images/vb-2-4a59b516-989f-4489-a502-604310293ce9.jpg.webp?h=a0982569&itok=VqJQrmYi 1x, /system/files/styles/visitberlin_teaser_search_visitberlin_desktop_2x/private/event_images/vb-2-4a59b516-989f-4489-a502-604310293ce9.jpg.webp?h=a0982569&itok=pyPxkjvR 2x',
          event_from: '03/2/2022',
          event_to: '31/12/2022',
          event_time_from: '08:00 am',
          event_time_to: nil,
          event_location: 'Verschiedene Orte'
        }
      end
      # rubocop:enable Layout/LineLength

      it { expect(scraper.events.count).to be(21) }
      it { expect(scraper.events.first).to eql(expected_event) }
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
