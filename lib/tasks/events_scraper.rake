# frozen_string_literal: true

namespace :events_scraper do
  desc 'scrape visit berlin site'
  task :run, %i[source paginate page_limit bulk] => :environment do |_, args|
    abort "Usage: rails 'events_scraper:run[source, paginate, page_limit, bulk]'" unless args[:source]

    paginate = args[:paginate] == 'true'
    page_limit = args[:page_limit].to_i
    bulk = args[:bulk] == 'true'

    case args[:source].to_sym
    when :visit_berlin
      start_url = ENV.fetch('VISIT_BERLIN_START_URL', nil)
      logger_path = ENV.fetch('VISIT_BERLIN_LOGGER_PATH', nil)

      VisitBerlinEventsScraper.set_config(:logger_path, logger_path) if logger_path.present?

      abort "missing ENV['VISIT_BERLIN_START_URL'] environment variable" if start_url.blank?
      scraper = VisitBerlinEventsScraper.new(start_url)

    when :gorki
      start_url = ENV.fetch('GORKI_START_URL', nil)
      logger_path = ENV.fetch('GORKI_LOGGER_PATH', nil)

      GorkiEventsScraper.set_config(:logger_path, logger_path) if logger_path.present?

      abort "missing ENV['GORKI_START_URL'] environment variable" if start_url.blank?
      scraper = GorkiEventsScraper.new(start_url)
    end

    abort "Invalid source: #{args[:source]}" unless scraper

    svc = CollectScraperEventsService.new(scraper)
    svc.call(paginate:, page_limit:, bulk:)

    puts "#{svc.events.count} events saved successfully"
    puts svc.failures.inspect if svc.failures.present?
  end
end
