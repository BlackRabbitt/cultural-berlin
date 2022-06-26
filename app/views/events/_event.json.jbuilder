# frozen_string_literal: true

json.extract! event, :id, :event_source, :event_url, :title, :category, :image_url, :event_from, :event_to,
              :event_time_from, :event_time_to, :event_location, :created_at, :updated_at
json.url event_url(event, format: :json)
