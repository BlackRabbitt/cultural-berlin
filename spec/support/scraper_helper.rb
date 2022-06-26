# frozen_string_literal: true

module ScraperHelper
  # helper to find local test files
  def test_response(uri)
    filename = [
      [
        uri.host,
        uri.path.presence && uri.path.gsub('/', '-')
      ].compact.join('_'),
      uri.query
    ].compact.join('?')
    File.read(Rails.root.join('spec', 'scrapers', 'fake_htmls', "#{filename}.html"))
  end

  def test_next_page_params(query)
    { query: }
  end
end
