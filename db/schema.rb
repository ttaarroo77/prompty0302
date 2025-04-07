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

ActiveRecord::Schema[7.1].define(version: 2025_04_05_113548) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_tag_suggestions", force: :cascade do |t|
    t.bigint "prompt_id", null: false
    t.string "name"
    t.float "confidence_score"
    t.boolean "applied"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_id"], name: "index_ai_tag_suggestions_on_prompt_id"
  end

  create_table "prompt_tags", force: :cascade do |t|
    t.bigint "prompt_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_id", "tag_id"], name: "index_prompt_tags_on_prompt_id_and_tag_id", unique: true
    t.index ["prompt_id"], name: "index_prompt_tags_on_prompt_id"
    t.index ["tag_id"], name: "index_prompt_tags_on_tag_id"
  end

  create_table "prompts", force: :cascade do |t|
    t.string "title", limit: 15, null: false
    t.text "content"
    t.text "notes"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "url"
    t.index ["user_id"], name: "index_prompts_on_user_id"
  end

  create_table "prompts_tags", id: false, force: :cascade do |t|
    t.bigint "prompt_id"
    t.bigint "tag_id"
    t.index ["prompt_id", "tag_id"], name: "index_prompts_tags_on_prompt_id_and_tag_id", unique: true
    t.index ["prompt_id"], name: "index_prompts_tags_on_prompt_id"
    t.index ["tag_id"], name: "index_prompts_tags_on_tag_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "prompt_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_id", "tag_id"], name: "index_taggings_on_prompt_id_and_tag_id", unique: true
    t.index ["prompt_id"], name: "index_taggings_on_prompt_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 21, null: false
    t.text "description"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "ai_tag_suggestions", "prompts"
  add_foreign_key "prompt_tags", "prompts"
  add_foreign_key "prompt_tags", "tags"
  add_foreign_key "prompts", "users"
  add_foreign_key "taggings", "prompts"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tags", "users"
end
