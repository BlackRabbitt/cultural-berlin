# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectScraperEventsService do
  let(:svc) { described_class.new(VisitBerlinEventsScraper.new('https://www.visitberlin.de/en/event-calendar-berlin')) }

  describe 'find_or_initialize_event' do
    subject(:event) { svc.find_or_initialize_event(event_params) }

    let(:event_params) do
      {
        event_id: '/en/event/adventure-buddy-bear-hunt-across-berlin',
        event_url: 'https://www.visitberlin.de/event/adventure-across-berlin',
        title: 'Adventure: Buddy Bear Hunt across Berlin',
        description: 'The Buddy Bears Berlin cityscape.',
        category: 'Walking Tour',
        image_url: 'https://www.visitberlin.de/489-a502-604310293ce9.jpg.webp',
        event_from: '03 Feb, 2022',
        event_to: '31 Dec, 2022',
        event_time_from: '08:00',
        event_time_to: nil,
        event_location: 'Verschiedene Orte',
        ticket_url: 'https://www.visitberlin.de/de/kudamm56_berlin/?source=bde'
      }
    end

    it { expect(event.event_source).to eql('www.visitberlin.de') }
    it { expect(event.event_id).to eql('/en/event/adventure-buddy-bear-hunt-across-berlin') }
    it { expect(event.event_url).to eql('https://www.visitberlin.de/event/adventure-across-berlin') }
    it { expect(event.title).to eql('Adventure: Buddy Bear Hunt across Berlin') }
    it { expect(event.description).to eql('The Buddy Bears Berlin cityscape.') }
    it { expect(event.category).to eql('Walking Tour') }
    it { expect(event.image_url).to eql('https://www.visitberlin.de/489-a502-604310293ce9.jpg.webp') }
    it { expect(event.event_from).to eql('03 Feb, 2022'.to_date) }
    it { expect(event.event_to).to eql('31 Dec, 2022'.to_date) }
    it { expect(event.event_time_from.strftime('%H:%M')).to eql('08:00') }
    it { expect(event.event_location).to eql('Verschiedene Orte') }
    it { expect(event.ticket_url).to eql('https://www.visitberlin.de/de/kudamm56_berlin/?source=bde') }
  end
end
