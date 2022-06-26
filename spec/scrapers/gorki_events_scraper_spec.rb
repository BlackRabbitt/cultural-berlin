# frozen_string_literal: true

require 'rails_helper'
require 'support/scraper_helper'

RSpec.describe GorkiEventsScraper do
  include ScraperHelper

  let(:scraper) { described_class.new('https://www.gorki.de') }

  before { allow(scraper).to receive(:html_document) { |uri| test_response(uri) } }

  it { expect(scraper.schedule_item_list.size).to be(9) }
  it { expect(scraper.start_url.to_s).to eql('https://www.gorki.de') }
  it { expect(scraper.current_page_params).to eql({ path: '/en/programme/2022/06/all' }) }
  it { expect(scraper.next_page_params).to eql({ path: '/en/programme/2022/07/all' }) }

  describe 'perform' do
    context 'with single page' do
      before { scraper.perform }

      it { expect(scraper.events.count).to be(16) }

      it 'navigates to current_page_params to prevent duplicate pages' do
        expect(scraper.pages.map(&:to_s)).to eql(['https://www.gorki.de/en/programme/2022/06/all'])
      end
    end

    context 'with all pages, no limit' do
      before { scraper.perform(paginate: true) }

      it { expect(scraper.events.count).to be(22) }

      it 'navigates to current_page_params to prevent duplicate pages' do
        expect(scraper.pages.map(&:to_s)).to eql(['https://www.gorki.de/en/programme/2022/06/all', 'https://www.gorki.de/en/programme/2022/07/all'])
      end
    end
  end

  describe 'parse_response' do
    context 'without block' do
      before { scraper.parse_response }

      it { expect(scraper.events.count).to be(16) }

      describe 'first event' do
        subject(:event) { scraper.events.first }

        it { expect(event[:event_id]).to eql('https://www.gorki.de/en/delaine-le-bas-exhibition/2022-06-22-1200') }
        it { expect(event[:event_url]).to eql('https://www.gorki.de/en/delaine-le-bas-exhibition/2022-06-22-1200') }
        it { expect(event[:title]).to eql('Delaine Le Bas | Ausstellung') }
        it { expect(event[:description]).to eql('') }
        it { expect(event[:note]).to eql("Exhibition | Installation | Performance | Talk\nÖffnungszeiten Ausstellung:\nMo - So: 12:00 - 20:00\nGorki Kiosk & Jurte\nEINTRITT FREI!") } # rubocop:disable Layout/LineLength
        it { expect(event[:category]).to eql('is-guest') }
        it { expect(event[:image_url]).to eql('https://www.gorki.de/sites/default/files/styles/small_l/public/2022-03/gorki_web_kachel_delaine-le-bas_beware-of_beware.jpg?itok=lI8_MHDr') } # rubocop:disable Layout/LineLength
        it { expect(event[:event_from]).to eql('22 Jun, 2022'.to_date) }
        it { expect(event[:event_to]).to be_nil }
        it { expect(event[:event_time_from]).to be_nil }
        it { expect(event[:event_time_to]).to be_nil }
        it { expect(event[:event_location]).to be_nil }
        it { expect(event[:ticket_url]).to be_nil }
      end

      describe 'second event' do
        subject(:event) { scraper.events.second }

        it { expect(event[:event_id]).to eql('https://www.gorki.de/en/the-situation/2022-06-22-1900') }
        it { expect(event[:event_url]).to eql('https://www.gorki.de/en/the-situation/2022-06-22-1900') }
        it { expect(event[:title]).to eql('The Situation') }
        it { expect(event[:description]).to eql('By Yael Ronen & Ensemble') }
        it { expect(event[:note]).to eql('With English surtitles') }
        it { expect(event[:category]).to be_nil }
        it { expect(event[:image_url]).to eql('https://www.gorki.de/sites/default/files/styles/small_l/public/the%20situation_neu.jpg?itok=H8tbPzZo') } # rubocop:disable Layout/LineLength
        it { expect(event[:event_from]).to eql('22 Jun, 2022'.to_date) }
        it { expect(event[:event_to]).to be_nil }
        it { expect(event[:event_time_from]).to eql('07:30pm'.to_time) }
        it { expect(event[:event_time_to]).to eql('09:00pm'.to_time) }
        it { expect(event[:event_location]).to be_nil }
        it { expect(event[:ticket_url]).to eql('https://tickets.gorki.de/eventim.webshop/webticket/shop?event=11609') }
      end
    end

    context 'with block provided' do
      let(:event_titles) { [] }

      before do
        scraper.parse_response { |evt| event_titles << evt[:title] }
      end

      it { expect(event_titles.size).to be(16) }
      it { expect(event_titles.first).to eql('Delaine Le Bas | Ausstellung') }
    end
  end
end
