# frozen_string_literal: true

module ScraperUtils
  class << self
    def format_url(url_string, default_url:)
      return unless url_string

      url_string = "https://#{url_string}" unless url_string[%r{\Ahttp://}] || url_string[%r{\Ahttps://}]

      url = URI.parse(url_string)
      url.scheme = default_url.scheme unless url.scheme
      url.host = default_url.host unless url.host

      url.to_s
    end

    def format_date(date_string, input_format)
      return unless date_string

      DateTime.strptime(date_string, input_format)
    rescue StandardError
      date_string
    end

    def format_time(time_string, input_format)
      return unless time_string

      Time.strptime(time_string, input_format)
    rescue StandardError
      time_string
    end
  end
end
