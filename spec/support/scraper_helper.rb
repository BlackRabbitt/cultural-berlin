# frozen_string_literal: true

module ScraperHelper
  def test_response(url)
    filename = [url.host, url.query].compact.join('?')

    File.read(Rails.root.join('spec', 'scrapers', 'fake_htmls', "#{filename}.html"))
  end
end
