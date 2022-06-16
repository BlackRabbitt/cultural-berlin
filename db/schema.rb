# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 20_220_618_102_824) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pgcrypto'
  enable_extension 'plpgsql'

  create_table 'events', force: :cascade do |t|
    t.integer 'event_source', null: false
    t.string 'event_id', null: false
    t.string 'event_url', null: false
    t.string 'title'
    t.text 'description'
    t.string 'category'
    t.string 'image_url'
    t.date 'event_date'
    t.date 'event_to'
    t.time 'event_time_from'
    t.time 'event_time_to'
    t.string 'event_location'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[event_id event_source], name: 'index_events_on_event_id_and_event_source', unique: true
    t.index ['event_id'], name: 'index_events_on_event_id'
  end
end
