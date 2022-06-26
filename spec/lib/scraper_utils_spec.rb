# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScraperUtils do
  describe 'self.format_url' do
    subject(:formatted_url) { described_class.format_url(url, default_url:) }

    let(:default_url) { URI.parse('https://www.visitberlin.de') }

    context 'with valid url' do
      let(:url) { 'https://sixxpaxx.com/theater-berlin/' }

      it { expect(formatted_url).to eql('https://sixxpaxx.com/theater-berlin/') }
    end

    context 'with path only url' do
      let(:url) { '/en/event/adventure-buddy-bear-hunt-across-berlin' }

      it { expect(formatted_url).to eql('https://www.visitberlin.de/en/event/adventure-buddy-bear-hunt-across-berlin') }
    end

    context 'with host only url' do
      let(:url) { 'www.visitberlin.de/en/event/adventure-buddy-bear-hunt-across-berlin' }

      it { expect(formatted_url).to eql('https://www.visitberlin.de/en/event/adventure-buddy-bear-hunt-across-berlin') }
    end

    context 'with full url' do
      let(:url) { 'https://www.youtube.com/watch?v=L5s6NcbqmVI/sourcebde' }

      it { expect(formatted_url).to eql('https://www.youtube.com/watch?v=L5s6NcbqmVI/sourcebde') }
    end

    context 'with null url' do
      let(:url) { nil }

      it { expect(formatted_url).to be_nil }
    end
  end

  describe 'self.format_date' do
    subject(:date) { described_class.format_date(date_string, input_format) }

    let(:input_format) { '%d/%m/%Y' }

    context 'with valid input' do
      let(:date_string) { '29/11/1992' }

      it { expect(date).to eql('29 Nov, 1992'.to_date) }
    end

    context 'with invalid input' do
      let(:date_string) { '1992/1/1' }

      it { expect(date).to eql('1992/1/1') }
    end
  end

  describe 'self.format_time' do
    let(:hr12) { '%I:%M %P' } # am/pm
    let(:hr24) { '%H:%M' } # 24hr

    it { expect(described_class.format_time('10:00 am', hr12)).to eql('10:00 am'.to_time) }
    it { expect(described_class.format_time('13:20', hr24)).to eql('01:20 pm'.to_time) }
  end
end
