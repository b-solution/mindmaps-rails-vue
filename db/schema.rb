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

ActiveRecord::Schema.define(version: 2019_08_15_145645) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "connections", force: :cascade do |t|
    t.float "parent_x"
    t.float "parent_y"
    t.float "child_x"
    t.float "child_y"
    t.bigint "mindmap_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mindmap_id"], name: "index_connections_on_mindmap_id"
  end

  create_table "mindmaps", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nodes", force: :cascade do |t|
    t.string "title"
    t.boolean "root"
    t.bigint "mindmap_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mindmap_id"], name: "index_nodes_on_mindmap_id"
  end

  add_foreign_key "connections", "mindmaps"
  add_foreign_key "nodes", "mindmaps"
end
