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

ActiveRecord::Schema[7.0].define(version: 2024_04_02_194159) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "workflow_metadata", force: :cascade do |t|
    t.string "druid", null: false
    t.integer "version", default: 1
    t.jsonb "values", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["druid"], name: "index_workflow_metadata_on_druid"
    t.index ["version"], name: "index_workflow_metadata_on_version"
  end

  create_table "workflow_steps", id: :serial, force: :cascade do |t|
    t.string "druid", null: false
    t.string "workflow", null: false
    t.string "process", null: false
    t.string "status"
    t.text "error_msg"
    t.binary "error_txt"
    t.integer "attempts", default: 0, null: false
    t.string "lifecycle"
    t.decimal "elapsed", precision: 9, scale: 3
    t.integer "version"
    t.text "note"
    t.string "lane_id", default: "default", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active_version", default: false
    t.datetime "completed_at", precision: nil
    t.index ["active_version", "status", "workflow", "process"], name: "active_version_step_name_workflow2_idx"
    t.index ["druid", "version"], name: "index_workflow_steps_on_druid_and_version"
    t.index ["druid"], name: "index_workflow_steps_on_druid"
    t.index ["status", "workflow", "process", "druid"], name: "step_name_with_druid_workflow2_idx"
    t.index ["status", "workflow", "process"], name: "step_name_workflow2_idx"
  end

end
