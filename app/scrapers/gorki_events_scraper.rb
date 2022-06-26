# frozen_string_literal: true

class GorkiEventsScraper < ApplicationScraper
  attr_reader :events

  set_config :date_format, '%d %b'
  set_config :time_format, '%I:%M%P'

  def initialize(start_url)
    @events = []

    super
  end

  def parse_response(&block)
    schedule_item_list.each do |item_list|
      day = item_list.css('.item-list--date .schedule-item-list--date--day').text

      item_list.css('.item-list--item').each do |event_container|
        event = parse_event(event_container)
                .merge(parse_event_date(event_container, day))
                .merge(parse_event_time(event_container))

        @events << event

        block&.call(event)
      end
    end
  end

  def schedule_item_list
    response.css('.schedule-overview .item-list')
  end

  def current_page_params
    { path: response.css('.schedule-filter--months--link.is-active').attribute('href').value }
  end

  def next_page_params
    { path: response.css('.schedule-link--item a').attribute('href')&.value }
  end

  private

  def parse_event(event_container)
    {
      event_id: event_id(event_container),
      event_url: ScraperUtils.format_url(event_url(event_container), default_url: start_url),
      title: event_title(event_container),
      description: event_description(event_container),
      note: event_note(event_container),
      category: event_category(event_container),
      image_url: ScraperUtils.format_url(image_url(event_container), default_url: start_url),
      ticket_url: ScraperUtils.format_url(event_ticket_url(event_container), default_url: start_url)
    }
  end

  def parse_event_date(_event_container, day)
    current_month = response.css('.schedule-filter--months--link.is-active').text&.humanize

    { event_from: ScraperUtils.format_date("#{day} #{current_month}", config.date_format) }
  end

  def parse_event_time(event_container)
    time_text = event_container.css('.is-headline-sub').text&.squish
    from, to_text = time_text.split(' - ')

    {
      event_time_from: ScraperUtils.format_time(from, config.time_format),
      event_time_to: ScraperUtils.format_time(to_text&.split(' ')&.first, config.time_format)
    }
  end

  def event_id(event_container)
    event_container.css('.item-list--row-item-content--image a').attribute('href')&.value
  end

  def event_url(event_container)
    event_container.css('.item-list--row-item-content--image a').attribute('href')&.value
  end

  def event_title(event_container)
    event_container.css('.item-list--row-item-content--image a').attribute('title')&.value
  end

  def event_description(event_container)
    event_container.css('.cast li').map do |c|
      c.text&.strip&.gsub("\n", ' ')&.squish
    end.join("\n")
  end

  def event_note(event_container)
    note = event_container.css('.field__item').text
    note.split("\n").compact_blank.map(&:squish).join("\n") if note.present?
  end

  def event_category(event_container)
    class_name = 'item-list--row-item-content'
    classes = event_container.css(".#{class_name}").attribute('class').value

    classes.split.detect { |cls| cls != class_name }
  end

  def image_url(event_container)
    urls = event_container.css('.item-list--row-item-content--image source[type="image/jpeg"]')
                          .attribute('srcset')&.value

    urls.split[0] if urls
  end

  def event_ticket_url(event_container)
    event_container.css('.button-wrapper a').attribute('href')&.value
  end
end
