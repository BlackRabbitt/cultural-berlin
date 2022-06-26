# frozen_string_literal: true

class Event < ApplicationRecord
  validates :event_source, presence: true
  validates :event_id, uniqueness: { scope: :event_source }

  enum event_source: { 'www.visitberlin.de' => 1, 'www.gorki.de' => 2 }

  class << self
    def search(params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      arel = Event.arel_table

      results = self
      results = where(arel[:title].matches("%#{sanitize_sql_like(params[:query])}%")) if params[:query].present?
      results = results.where(arel[:event_source].eq(params[:source])) if params[:source].present?
      if params[:event_date].present?
        # search events available at params_event_date
        results = results.where(arel[:event_from].eq(nil).or(arel[:event_from].lteq(params[:event_date])))
                         .where(arel[:event_to].eq(nil).or(arel[:event_to].gteq(params[:event_date])))
      end

      if params[:event_time].present?
        # search events available at params_event_time
        utc_time_param = params[:event_time].to_time.utc.strftime('%H:%M')
        results = results.where(arel[:event_time_from].eq(nil).or(arel[:event_time_from].lteq(utc_time_param)))
                         .where(arel[:event_time_to].eq(nil).or(arel[:event_time_to].gteq(utc_time_param)))
      end

      results
    end
  end
end
