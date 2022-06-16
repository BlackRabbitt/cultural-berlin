# frozen_string_literal: true

module Events
  class VisitBerlinScraper < BaseScraper
    def initialize
      super('https://www.visitberlin.de/en/event-calendar-berlin')
    end

    def event_containers
      response.css('ul.l-list li.l-list__item')
    end

    def next_page_params
      next_page = response.css('.pager__item--next a').attribute('href').value

      { query: next_page.present? && next_page.split('?')[1] }
    end

    private

    def event_id(event_container)
      event_container.css('article.teaser-search').attribute('about').value
    end

    def event_url(event_container)
      event_container.css('a[style="display:contents;"]').attribute('href').value
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
      event_container.css('picture source[type="image/webp"]').first.attribute('srcset').value
    end

    def event_from(event_container)
      event_container.css('p.teaser-search__date .heading-highlight__inner time').first.text
    end

    def event_to(event_container)
      event_container.css('p.teaser-search__date .heading-highlight__inner time').last.text
    end

    def event_location(event_container)
      event_container.css('.teaser-search__location .me__content .nopr').text
    end

    def event_time_from(event_container)
      event_container.css('.teaser-search__time .me__content').text
    end

    def event_time_to(_event_container)
      nil
    end
  end
end
