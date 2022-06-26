# frozen_string_literal: true

class ApplicationScraper
  include ActiveSupport::Configurable

  attr_reader :start_url, :pages, :logger

  class << self
    def set_config(key, value)
      config.send("#{key}=", value)
    end
  end

  set_config :logger_path, "log/scraper_#{Rails.env}.log"

  def initialize(start_url)
    @pages = []
    @start_url = URI.parse(start_url)

    @logger = Logger.new(config.logger_path)
    @logger.formatter = proc do |severity, datetime, _progname, msg|
      "#{datetime}, #{severity}: #{msg} \n"
    end
  end

  def perform(paginate: false, page_limit: 0, &block)
    navigate_to_current_page(current_page_params)

    @pages << start_url.dup

    @logger.debug("Parsing response for: #{start_url}")
    parse_response(&block)

    navigate(next_page_params)

    if !paginate || @pages.include?(start_url) || page_limit_reached?(page_limit)
      @logger.debug("Finished parsing following pages: #{pages.map(&:to_s)}.")

      return
    end

    @logger.debug("Navigating to next page: #{start_url}")
    perform(paginate: true, page_limit:, &block)
  end

  # html response for page defined by `start_url`
  def response
    @response = Nokogiri::HTML(html_document(start_url))
  end

  # parse single html response defined by `start_url`
  def parse_response(&)
    raise NotImplementedError
  end

  # optional, parse next page url
  #
  # for pagination - next page nav value
  def next_page_params
    {}
  end

  # optional, parse current page url
  #
  # for pagination
  # if `?page=last` loops back to `?page=1` such that `?page=1` != `start_url`
  # to prevent parsing duplicate page
  def current_page_params
    {}
  end

  def navigate(params = {})
    @start_url.query = params[:query] if params[:query].present?
    @start_url.path = params[:path] if params[:path].present?

    @start_url
  end

  def navigate_to_current_page(params = {})
    return if params.blank?

    current_page_url = start_url.dup
    current_page_url.query = params[:query] if params[:query].present?
    current_page_url.path = params[:path] if params[:path].present?

    return if start_url == current_page_url

    @logger.debug('`current_page_url` is different from `start_url`')
    @logger.debug("Navigating from: #{start_url} to: #{current_page_url}")
    navigate({ path: current_page_url.path, query: current_page_url.query })
  end

  private

  def html_document(uri)
    uri.open
  end

  def page_limit_reached?(page_limit)
    page_limit.positive? && @pages.size >= page_limit
  end
end
