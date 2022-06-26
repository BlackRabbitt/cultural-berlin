# frozen_string_literal: true

class CollectScraperEventsService
  attr_reader :events, :failures, :scraper

  def initialize(scraper)
    @scraper = scraper
  end

  def call(paginate: true, page_limit: 0, bulk: true) # rubocop:disable Metrics/MethodLength
    @events = []
    @failures = []

    scraper.perform(paginate:, page_limit:) do |event_params|
      next if @events.detect { |evt| evt.event_id == event_params[:event_id] } # ignore duplicate events

      event = find_or_initialize_event(event_params)

      if event.valid?
        event.save unless bulk

        @events << event
      else
        @failures << event.errors
      end
    end

    bulk_save_to_db if bulk && @failures.blank?
  end

  def find_or_initialize_event(event_params)
    present_time = Time.zone.now

    event = Event.find_or_initialize_by(event_source: scraper.start_url.host, event_id: event_params[:event_id])
    event.assign_attributes(event_params)
    event.created_at = present_time if event.new_record?
    event.updated_at = present_time

    event
  end

  private

  def bulk_save_to_db
    # rubocop:disable Rails/SkipsModelValidations
    Event.upsert_all(bulk_events_params, unique_by: :index_events_on_event_id_and_event_source)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def bulk_events_params
    # delete event id as we rely on uniq index_events_on_event_id_and_event_source
    JSON.parse(@events.to_json).each { |r| r.delete('id') }
  end
end
