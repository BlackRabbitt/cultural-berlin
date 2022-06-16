# frozen_string_literal: true

module Events
  class BaseScraper < ApplicationScraper
    attr_reader :events

    def initialize(start_url)
      @events = []

      super(start_url)
    end

    def parse_response(&block)
      event_containers.each do |event_container|
        event = parse_event(event_container)

        @events << event

        block&.call(event)
      end
    end

    def event_containers
      raise NotImplementedError
    end

    def next_page_params
      raise NotImplementedError
    end

    private

    def parse_event(event_container) # rubocop:disable Metrics/MethodLength
      {
        event_id: event_id(event_container),
        event_url: event_url(event_container),
        title: event_title(event_container),
        description: event_description(event_container),
        category: event_category(event_container),
        image_url: image_url(event_container),
        event_from: event_from(event_container),
        event_to: event_to(event_container),
        event_time_from: event_time_from(event_container)&.squish,
        event_time_to: event_time_to(event_container)&.squish,
        event_location: event_location(event_container)
      }
    end
  end
end
