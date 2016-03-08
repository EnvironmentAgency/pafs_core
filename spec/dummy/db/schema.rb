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

ActiveRecord::Schema.define(version: 20160307131830) do

  create_table "dsc_address_contacts", id: false, force: :cascade do |t|
    t.integer "address_id", null: false
    t.integer "contact_id", null: false
  end

  add_index "dsc_address_contacts", ["address_id"], name: "index_dsc_address_contacts_on_address_id"
  add_index "dsc_address_contacts", ["contact_id"], name: "index_dsc_address_contacts_on_contact_id"

  create_table "dsc_address_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dsc_addresses", force: :cascade do |t|
    t.string   "premises",            limit: 200
    t.string   "street_address",      limit: 160
    t.string   "locality",            limit: 70
    t.string   "city",                limit: 30
    t.string   "postcode",            limit: 8
    t.integer  "county_province_id"
    t.string   "country_iso",         limit: 3
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "address_type",                    default: 0,  null: false
    t.string   "organisation",        limit: 255, default: "", null: false
    t.date     "state_date"
    t.string   "blpu_state_code"
    t.string   "postal_address_code"
    t.string   "logical_status_code"
  end

  create_table "dsc_contacts", force: :cascade do |t|
    t.integer  "contact_type",                   default: 0, null: false
    t.integer  "title",                          default: 0, null: false
    t.string   "suffix",             limit: 255
    t.string   "first_name",         limit: 255
    t.string   "last_name",          limit: 255
    t.date     "date_of_birth"
    t.string   "position",           limit: 255
    t.string   "email_address",      limit: 255
    t.date     "valid_from"
    t.date     "valid_to"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "primary_address_id"
  end

  add_index "dsc_contacts", ["primary_address_id"], name: "index_dsc_contacts_on_primary_address_id"

  create_table "dsc_county_provinces", force: :cascade do |t|
    t.string   "name"
    t.string   "abbr"
    t.string   "country_iso", limit: 3
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "dsc_enrollments", force: :cascade do |t|
    t.string   "state"
    t.boolean  "under_review",              default: false
    t.datetime "submitted_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "parties_id"
    t.integer  "applicant_contact_id"
    t.integer  "correspondence_contact_id"
    t.string   "token"
    t.integer  "status",                    default: 0,     null: false
  end

  add_index "dsc_enrollments", ["applicant_contact_id"], name: "index_dsc_enrollments_on_applicant_contact_id"
  add_index "dsc_enrollments", ["correspondence_contact_id"], name: "index_dsc_enrollments_on_correspondence_contact_id"
  add_index "dsc_enrollments", ["parties_id"], name: "index_dsc_enrollments_on_parties_id"
  add_index "dsc_enrollments", ["state"], name: "index_dsc_enrollments_on_state"
  add_index "dsc_enrollments", ["submitted_at"], name: "index_dsc_enrollments_on_submitted_at"

  create_table "dsc_locations", force: :cascade do |t|
    t.integer  "address_id"
    t.string   "grid_reference"
    t.string   "uprn"
    t.string   "lat"
    t.string   "long"
    t.string   "x"
    t.string   "y"
    t.date     "valid_from"
    t.date     "valid_to"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "coordinate_system"
  end

  create_table "dsc_organisations", force: :cascade do |t|
    t.string   "type"
    t.string   "name",           limit: 255
    t.integer  "contact_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "company_number", limit: 255
  end

  create_table "dsc_parties", force: :cascade do |t|
    t.string   "type"
    t.string   "description"
    t.date     "valid_from"
    t.date     "valid_to"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "dsc_phone_numbers", force: :cascade do |t|
    t.integer  "number_type",             default: 0, null: false
    t.string   "tel_number",  limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "contact_id"
  end

  add_index "dsc_phone_numbers", ["contact_id"], name: "index_dsc_phone_numbers_on_contact_id"

  create_table "dsc_roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "dsc_roles", ["name", "resource_type", "resource_id"], name: "index_dsc_roles_on_name_and_resource_type_and_resource_id"
  add_index "dsc_roles", ["name"], name: "index_dsc_roles_on_name"

  create_table "dsc_user_versions", force: :cascade do |t|
    t.string   "item_type",                     null: false
    t.integer  "item_id",                       null: false
    t.string   "event",                         null: false
    t.string   "whodunnit"
    t.text     "object",     limit: 1073741823
    t.datetime "created_at"
  end

  add_index "dsc_user_versions", ["item_type", "item_id"], name: "index_dsc_user_versions_on_item_type_and_item_id"

  create_table "dsc_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "role_names"
  end

  add_index "dsc_users", ["email"], name: "index_dsc_users_on_email", unique: true
  add_index "dsc_users", ["reset_password_token"], name: "index_dsc_users_on_reset_password_token", unique: true

  create_table "dsc_users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "dsc_users_roles", ["user_id", "role_id"], name: "index_dsc_users_roles_on_user_id_and_role_id"

  create_table "dsc_versions", force: :cascade do |t|
    t.string   "item_type",                     null: false
    t.integer  "item_id",                       null: false
    t.string   "event",                         null: false
    t.string   "whodunnit"
    t.text     "object",     limit: 1073741823
    t.datetime "created_at"
  end

  add_index "dsc_versions", ["item_type", "item_id"], name: "index_dsc_versions_on_item_type_and_item_id"

  create_table "pafs_core_projects", force: :cascade do |t|
    t.string   "reference_number", null: false
    t.integer  "version",          null: false
    t.string   "name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "pafs_core_projects", ["reference_number", "version"], name: "index_pafs_core_projects_on_reference_number_and_version", unique: true

end
