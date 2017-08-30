# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141104190821) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", force: true do |t|
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "attachments", ["client_id"], name: "index_attachments_on_client_id", using: :btree

  create_table "client_infos", force: true do |t|
    t.string   "name",                                null: false
    t.string   "position"
    t.string   "guid"
    t.string   "model_name",             default: ""
    t.string   "serial_number",          default: ""
    t.datetime "product_date_time"
    t.binary   "hw_config",              default: ""
    t.integer  "client_status",          default: 0,  null: false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zipupdate_file_name"
    t.string   "zipupdate_content_type"
    t.integer  "zipupdate_file_size"
    t.datetime "zipupdate_updated_at"
    t.string   "static_ip",              default: ""
  end

  create_table "client_sensors", force: true do |t|
    t.integer  "client_id"
    t.integer  "sensor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_sensors", ["client_id"], name: "index_client_sensors_on_client_id", using: :btree
  add_index "client_sensors", ["sensor_id"], name: "index_client_sensors_on_sensor_id", using: :btree

  create_table "clients", force: true do |t|
    t.string   "static_ip",          default: ""
    t.integer  "ordinal_num"
    t.integer  "sampling_time",      default: 30
    t.integer  "samples_count",      default: 10
    t.datetime "last_config"
    t.integer  "operator_id"
    t.integer  "client_info_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default_attachment"
  end

  create_table "data_samples", force: true do |t|
    t.datetime "sample_time"
    t.integer  "ordinal_num"
    t.integer  "client_ordinal_num"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_values", force: true do |t|
    t.integer  "sample_ordinal_num"
    t.integer  "channel_index"
    t.datetime "sample_time"
    t.integer  "client_id"
    t.integer  "sensor_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sensors", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "channel_index"
    t.integer  "code"
    t.integer  "unit_code"
    t.string   "unit_avb"
    t.integer  "saving_type"
    t.integer  "channel_type"
    t.integer  "hw_port_type"
    t.integer  "hw_port_number"
    t.integer  "hw_port_pin_number"
    t.integer  "calculation_type"
    t.boolean  "is_active"
    t.binary   "calibration_table_bin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "measure_unit",          default: ""
  end

  create_table "users", force: true do |t|
    t.string   "username",               default: "", null: false
    t.string   "name",                   default: "", null: false
    t.string   "email",                  default: ""
    t.string   "encrypted_password",     default: "", null: false
    t.integer  "user_type",              default: 0
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
