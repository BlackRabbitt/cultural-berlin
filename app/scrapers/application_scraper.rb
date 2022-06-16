# frozen_string_literal: true

require 'open-uri'

class ApplicationScraper
  attr_reader :start_url, :pages

  def initialize(start_url)
    @start_url = URI.parse(start_url)
    @pages = [@start_url.to_s]
  end

  # `page_limit: 0` with `paginate: true` will follow pagination until the end of pagination
  def perform(paginate: false, page_limit: 0, &block)
    parse_response(&block)

    next_page_url = navigate(next_page_params)

    return if !paginate || @pages.include?(next_page_url) || page_limit_reached?(page_limit)

    @pages << next_page_url

    perform(paginate: true, page_limit:, &block)
  end

  # navigate to `next_page_params`
  # after navigate, next call on `response` will return next_page defined by `next_page_params`
  def navigate(next_page_params = {})
    @start_url.query = next_page_params[:query] if next_page_params[:query].present?

    @start_url.to_s
  end

  # html response for page defined by `start_url`
  def response
    @response = Nokogiri::HTML(open_page)
  end

  # parse single html response defined by `start_url`
  def parse_response(&)
    raise NotImplementedError
  end

  private

  def open_page
    URI.parse(@start_url.to_s).open
  end

  def next_page_params
    raise NotImplementedError
  end

  def page_limit_reached?(page_limit)
    page_limit.positive? && @pages.size >= page_limit
  end
end
