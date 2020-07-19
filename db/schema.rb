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

ActiveRecord::Schema.define(version: 20200719111259) do

  create_table "container_data", force: :cascade do |t|
    t.text     "data"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "container_id"
    t.index ["container_id"], name: "index_container_data_on_container_id"
  end

  create_table "container_lists", force: :cascade do |t|
    t.text     "code"
    t.text     "key"
    t.text     "shipment_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "bill_of_lading"
    t.string   "bill_of_lading_bookmark_id"
    t.string   "subscription_id"
  end

  create_table "container_vessels", force: :cascade do |t|
    t.integer  "container_id"
    t.integer  "vessel_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["container_id"], name: "index_container_vessels_on_container_id"
    t.index ["vessel_id"], name: "index_container_vessels_on_vessel_id"
  end

  create_table "containers", force: :cascade do |t|
    t.text     "number"
    t.text     "container_type"
    t.decimal  "weight"
    t.text     "iso"
    t.text     "name"
    t.text     "status"
    t.text     "carrier_name"
    t.text     "carrier_scac"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "status_code"
    t.text     "source"
    t.text     "bill_number"
    t.text     "size"
  end

  create_table "location_timelines", force: :cascade do |t|
    t.text     "initial_time"
    t.text     "last_time"
    t.text     "expected_time"
    t.text     "actual_time"
    t.text     "detected_time"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "location_id"
    t.text     "timeline_type"
    t.index ["location_id"], name: "index_location_timelines_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.integer  "location_type"
    t.text     "code"
    t.text     "raw"
    t.text     "location_type_name"
    t.text     "port_code"
    t.text     "port_name"
    t.text     "lat"
    t.text     "long"
    t.text     "timezone"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "container_id"
    t.integer  "vessel_id"
    t.text     "timestamp"
    t.text     "name"
    t.text     "event_raw"
    t.text     "event_time"
    t.text     "event_type_code"
    t.text     "event_type_name"
    t.index ["container_id"], name: "index_locations_on_container_id"
    t.index ["vessel_id"], name: "index_locations_on_vessel_id"
  end

  create_table "ocean_insight_geo_tracks", force: :cascade do |t|
    t.string   "track_id"
    t.string   "transport_mode_verbose"
    t.string   "pos_source_verbose"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "vessel_speed_over_ground"
    t.string   "vessel_course_over_ground"
    t.string   "vessel_shipname"
    t.string   "vessel_callsign"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "vessel_logs", force: :cascade do |t|
    t.text     "log"
    t.integer  "vessel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "next_port"
    t.index ["vessel_id"], name: "index_vessel_logs_on_vessel_id"
  end

  create_table "vessels", force: :cascade do |t|
    t.text     "number"
    t.text     "name"
    t.text     "imo"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "container_id"
    t.text     "ais"
    t.text     "status"
    t.text     "status_code"
    t.text     "target_port_code"
    t.text     "target_port_name"
    t.index ["container_id"], name: "index_vessels_on_container_id"
  end

end
