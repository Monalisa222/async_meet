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

ActiveRecord::Schema[8.1].define(version: 2026_02_26_081503) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "meetings", force: :cascade do |t|
    t.boolean "ai_processed", default: false
    t.text "ai_summary"
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.text "description"
    t.integer "duration_minutes"
    t.string "meeting_url"
    t.bigint "organization_id", null: false
    t.datetime "scheduled_at"
    t.integer "status", default: 0, null: false
    t.string "title"
    t.text "transcript"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_meetings_on_creator_id"
    t.index ["organization_id"], name: "index_meetings_on_organization_id"
    t.index ["scheduled_at"], name: "index_meetings_on_scheduled_at"
  end

  create_table "memberships", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "industry"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["name"], name: "index_organizations_on_name"
  end

  create_table "tasks", force: :cascade do |t|
    t.boolean "ai_generated", default: false
    t.bigint "assigned_user_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.bigint "meeting_id", null: false
    t.bigint "organization_id", null: false
    t.integer "priority", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["assigned_user_id"], name: "index_tasks_on_assigned_user_id"
    t.index ["meeting_id"], name: "index_tasks_on_meeting_id"
    t.index ["organization_id"], name: "index_tasks_on_organization_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "meetings", "organizations"
  add_foreign_key "meetings", "users", column: "creator_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "tasks", "meetings"
  add_foreign_key "tasks", "organizations"
  add_foreign_key "tasks", "users", column: "assigned_user_id"
end
