# frozen_string_literal: true

class VisitBerlinEventsScraper < ApplicationScraper
  attr_reader :events

  set_config :date_format, '%d/%m/%Y'
  set_config :time_format, '%I:%M %P'

  def initialize(start_url)
    @events = []

    super
  end

  def parse_response(&block)
    event_containers.each do |event_container|
      event = parse_event(event_container)
              .merge(parse_event_date(event_container))
              .merge(parse_event_time(event_container))

      @events << event

      block&.call(event)
    end
  end

  def event_containers
    response.css('ul.l-list li.l-list__item')
  end

  def next_page_params
    next_page = response.css('.pager__item--next a').attribute('href')&.value

    { query: next_page.present? && next_page.split('?')[1] }
  end

  private

  def parse_event(event_container)
    {
      event_id: event_id(event_container),
      event_url: ScraperUtils.format_url(event_url(event_container), default_url: start_url),
      title: event_title(event_container),
      description: event_description(event_container),
      category: event_category(event_container),
      image_url: ScraperUtils.format_url(image_url(event_container), default_url: start_url),
      event_location: event_location(event_container),
      ticket_url: ScraperUtils.format_url(event_ticket_url(event_container), default_url: start_url)
    }
  end

  def parse_event_date(event_container)
    {
      event_from: ScraperUtils.format_date(event_from(event_container), config[:date_format]),
      event_to: ScraperUtils.format_date(event_to(event_container), config[:date_format])
    }
  end

  def parse_event_time(event_container)
    {
      event_time_from: ScraperUtils.format_time(event_time_from(event_container)&.squish, config[:time_format])
    }
  end

  def event_id(event_container)
    event_container.css('article.teaser-search').attribute('about')&.value
  end

  def event_url(event_container)
    event_container.css('a[style="display:contents;"]').attribute('href')&.value
  end

  def event_title(event_container)
    event_container.css('h2.teaser-search__heading .heading-highlight__inner').text
  end

  def event_description(event_container)
    event_container.css('.teaser-search__text div').text
  end

  def event_category(event_container)
    event_container.css('.teaser-search__category a.category-label').text
  end

  def image_url(event_container)
    urls = event_container.css('picture source[type="image/webp"]').attribute('srcset')&.value

    urls.split[0]
  end

  def event_from(event_container)
    event_container.css('p.teaser-search__date .heading-highlight__inner time').first&.text
  end

  def event_to(event_container)
    event_container.css('p.teaser-search__date .heading-highlight__inner time').last&.text
  end

  def event_location(event_container)
    event_container.css('.teaser-search__location .me__content .nopr').text
  end

  def event_time_from(event_container)
    event_container.css('.teaser-search__time .me__content').text
  end

  def event_ticket_url(event_container)
    event_container.css('.teaser-search__cta a').attribute('href')&.value
  end
end
