# Cultural Berlin - Scraper Project

## Web Sources used in this project:
1. https://www.visitberlin.de/en/event-calendar-berlin
2. https://www.gorki.de/en/programme/2022/02/all

## Project Prerequisite

Project is built with **ruby-3.1.0** and **rails-7.0.1**.

**PostgreSQL 13.6** is being used as database server and **Rspec** for testing framework.

`turbo-rails` use default `async` adapter in development. However, make sure to have **redis-server** running in staging and production.

## Installation
```bash
$ git clone git@github.com:BlackRabbitt/cultural-berlin.git
$ cd cultural-berlin
$ bundle install

$ cp env.example .env
# Setup DB_HOST, DB_USER, DB_PASS environment variable
# use `.env` in development to manage environment variable

$ bundle exec rails db:setup
$ bundle exec rails s # runs server in default 3000 PORT

$ bundle exec rspec  # run tests

$ whenever --update-crontab # please refer to schedule.rb for job definitions

# Run scraper for visit-berlin. ENV[VISIT_BERLIN_START_URL]
$ rails 'events_scraper:run[visit_berlin, true, 0, true]'

# Run scraper for gorki. ENV[GORKI_START_URL]
$ rails 'events_scraper:run[gorki, true, 0, true]'
```

## ApplicationScraper

This class provides interface to extract information from online web sources. Web sources should inherit this class and implement their own rule of parsing.

*Example implementation:*

```ruby
# app/scrapers/some_scraper.rb
class SomeScraper < ApplicationScraper
  set_config :date_format, SOURCE_DEFAULT_DATE_FORMAT
  set_config :time_format, SOURCE_DEFAULT_TIME_FORMAT
  set_config :logger_path, SOME_SCRAPER_LOGGER_PATH

  # required, parse html response available
  def parse_response(&block)
    # `response` is html document for given `@start_url` page
    data = do_anything_with(response.css('.some-class'))
    # call block on collected parsed data from response
    # so all data manipulation can be performed in single run/loop.
    block&.call(data)
  end

  # optional, parse next page url
  #
  # for pagination - next page nav value
  def next_page_params
    { query: 'page=2', path: '/or-use-path/for-next-page' }
  end

  # optional, parse current page url
  #
  # for pagination
  # if `?page=last` loops back to `?page=1` such that `?page=1` != `start_url`
  # to prevent parsing duplicate page
  def current_page_params
    { query: 'page=1', path: '/or-use-path/for-current/active-page' }
  end
end

# initialize scraper with `start_url`
scraper = SomeScraper.new('somesource.com/list_or_single_page')
scraper.perform(paginate: false, page_limit: 0) do |data|
  # do anything with your individual data collected from parsing response
  # example,
  Data.save(data_params(data)) # or,
  DataService.got_new_data(data) # or,
  BulkDataSaveService.append(data) # or,
  # or anything you wanted to do with parsed data from each page
end
puts scraper.pages # collection of urls that has been parsed
```

## Rake Task
```
$ rails 'events_scraper:run[SOURCE_NAME, PAGINATE, PAGE_LIMIT, BULK]'

# all pages starting from start_url and bulk save final array
$ rails 'events_scraper:run[visit_berlin, true, 0, true]'

# all pages starting from start_url and save each record
$ rails 'events_scraper:run[visit_berlin, true, 0, false]'

# first page only
$ rails 'events_scraper:run[gorki, false, 0, true]'

# paginate upto 5 pages limit
$ rails 'events_scraper:run[gorki, true, 5, true]'
```

## Logging
```bash
# default_logger_path = log/scraper_#{Rails.env}.log
# customizable via environment variable
# gorki: ENV[GORKI_LOGGER_PATH]
# visit-berling: ENV[VISIT_BERLIN_LOGGER_PATH]
```
