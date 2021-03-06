# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190529133009) do

  create_table "event_dates", force: :cascade do |t|
    t.string  "tm_event_date_id"
    t.string  "event_date_name"
    t.string  "url"
    t.string  "start_date"
    t.string  "start_time"
    t.integer "event_id"
    t.integer "venue_id"
  end

  create_table "events", force: :cascade do |t|
    t.string  "tm_event_id"
    t.string  "event_name"
    t.string  "url"
    t.integer "segment_id"
    t.integer "genre_id"
    t.integer "sub_genre_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string  "tm_genre_id"
    t.string  "genre_name"
    t.integer "segment_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.integer "rating"
    t.text    "review"
  end

  create_table "segments", force: :cascade do |t|
    t.string "tm_segment_id"
    t.string "segment_name"
  end

  create_table "sub_genres", force: :cascade do |t|
    t.string  "tm_sub_genre_id"
    t.string  "sub_genre_name"
    t.integer "genre_id"
  end

  create_table "user_events", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_date_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "city"
    t.string "country"
  end

  create_table "venues", force: :cascade do |t|
    t.string "tm_venue_id"
    t.string "venue_name"
    t.string "url"
    t.string "postcode"
    t.string "city"
    t.string "country"
  end

end
