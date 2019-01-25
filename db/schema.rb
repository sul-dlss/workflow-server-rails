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

ActiveRecord::Schema.define(version: 2019_01_25_161810) do

  create_table "workflow_steps", force: :cascade do |t|
    t.string "druid", null: false
    t.string "workflow", null: false
    t.string "process", null: false
    t.string "status"
    t.text "error_msg"
    t.binary "error_txt"
    t.integer "attempts", default: 0, null: false
    t.string "lifecycle"
    t.decimal "elapsed", precision: 9, scale: 3
    t.string "repository"
    t.integer "version"
    t.text "note"
    t.integer "priority", default: 0
    t.string "lane_id", default: "default", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["druid", "version"], name: "index_workflow_steps_on_druid_and_version"
    t.index ["druid"], name: "index_workflow_steps_on_druid"
  end

end
