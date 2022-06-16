# frozen_string_literal: true

class Event < ApplicationRecord
  validates :event_source, :event_url, presence: true
  validates :event_id, uniqueness: { scope: :event_source }

  enum event_source: { visit_berlin: 1 }
end
