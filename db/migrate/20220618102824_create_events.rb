# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.integer :event_source, null: false
      t.string :event_id, null: false
      t.string :event_url
      t.string :title
      t.text :description
      t.text :note
      t.string :category
      t.string :image_url
      t.date :event_from
      t.date :event_to
      t.time :event_time_from
      t.time :event_time_to
      t.string :event_location
      t.string :ticket_url

      t.timestamps
    end

    add_index :events, :event_id
    add_index :events, %i[event_id event_source], unique: true
  end
end
