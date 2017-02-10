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

ActiveRecord::Schema.define(version: 20170208175027) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "deactivated_taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type",    limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",      limit: 255
    t.integer  "deactivator_id"
    t.string   "deactivator_type", limit: 255
    t.string   "context",          limit: 255
    t.datetime "created_at"
  end

  add_index "deactivated_taggings", ["deactivator_id", "deactivator_type"], name: "d_taggings_deactivator_idx", using: :btree
  add_index "deactivated_taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "d_taggings_idx", using: :btree
  add_index "deactivated_taggings", ["taggable_id", "taggable_type", "context"], name: "d_taggings_type_idx", using: :btree
  add_index "deactivated_taggings", ["taggable_type", "context"], name: "index_deactivated_taggings_on_taggable_type_and_context", using: :btree

  create_table "documentations", force: :cascade do |t|
    t.string   "match_key",   limit: 100,                    null: false
    t.string   "title",       limit: 500,                    null: false
    t.string   "description", limit: 1048576
    t.string   "lang",        limit: 2,       default: "en"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "documentations", ["lang"], name: "index_documentations_on_lang", using: :btree
  add_index "documentations", ["match_key"], name: "index_documentations_on_match_key", unique: true, using: :btree
  add_index "documentations", ["title"], name: "index_documentations_on_title", using: :btree

  create_table "feed_items", force: :cascade do |t|
    t.string   "title",          limit: 500
    t.string   "url",            limit: 2048
    t.string   "guid",           limit: 1024
    t.string   "authors",        limit: 1024
    t.string   "contributors",   limit: 1024
    t.string   "description",    limit: 5120
    t.string   "content",        limit: 1048576
    t.string   "rights",         limit: 500
    t.datetime "date_published"
    t.datetime "last_updated"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "image_url"
  end

  add_index "feed_items", ["authors"], name: "index_feed_items_on_authors", using: :btree
  add_index "feed_items", ["contributors"], name: "index_feed_items_on_contributors", using: :btree
  add_index "feed_items", ["date_published"], name: "index_feed_items_on_date_published", using: :btree
  add_index "feed_items", ["url"], name: "index_feed_items_on_url", unique: true, using: :btree

  create_table "feed_items_feed_retrievals", id: false, force: :cascade do |t|
    t.integer "feed_item_id"
    t.integer "feed_retrieval_id"
  end

  add_index "feed_items_feed_retrievals", ["feed_item_id"], name: "index_feed_items_feed_retrievals_on_feed_item_id", using: :btree
  add_index "feed_items_feed_retrievals", ["feed_retrieval_id"], name: "index_feed_items_feed_retrievals_on_feed_retrieval_id", using: :btree

  create_table "feed_items_feeds", id: false, force: :cascade do |t|
    t.integer "feed_id"
    t.integer "feed_item_id"
  end

  add_index "feed_items_feeds", ["feed_id"], name: "index_feed_items_feeds_on_feed_id", using: :btree
  add_index "feed_items_feeds", ["feed_item_id"], name: "index_feed_items_feeds_on_feed_item_id", using: :btree

  create_table "feed_retrievals", force: :cascade do |t|
    t.integer  "feed_id"
    t.boolean  "success"
    t.string   "info",        limit: 5120
    t.string   "status_code", limit: 25
    t.string   "changelog",   limit: 1048576
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "feeds", force: :cascade do |t|
    t.string   "title",                    limit: 500
    t.string   "description",              limit: 2048
    t.string   "guid",                     limit: 1024
    t.datetime "last_updated"
    t.datetime "items_changed_at"
    t.string   "rights",                   limit: 500
    t.string   "authors",                  limit: 1024
    t.string   "feed_url",                 limit: 1024,                 null: false
    t.string   "link",                     limit: 1024
    t.string   "generator",                limit: 500
    t.string   "flavor",                   limit: 25
    t.string   "language",                 limit: 25
    t.boolean  "bookmarking_feed",                      default: false
    t.datetime "next_scheduled_retrieval"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "feeds", ["authors"], name: "index_feeds_on_authors", using: :btree
  add_index "feeds", ["bookmarking_feed"], name: "index_feeds_on_bookmarking_feed", using: :btree
  add_index "feeds", ["feed_url"], name: "index_feeds_on_feed_url", using: :btree
  add_index "feeds", ["flavor"], name: "index_feeds_on_flavor", using: :btree
  add_index "feeds", ["generator"], name: "index_feeds_on_generator", using: :btree
  add_index "feeds", ["guid"], name: "index_feeds_on_guid", using: :btree
  add_index "feeds", ["next_scheduled_retrieval"], name: "index_feeds_on_next_scheduled_retrieval", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",               null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "hub_feeds", force: :cascade do |t|
    t.integer  "feed_id",                  null: false
    t.integer  "hub_id",                   null: false
    t.string   "title",       limit: 500
    t.string   "description", limit: 2048
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "hub_feeds", ["feed_id"], name: "index_hub_feeds_on_feed_id", using: :btree
  add_index "hub_feeds", ["hub_id", "feed_id"], name: "index_hub_feeds_on_hub_id_and_feed_id", unique: true, using: :btree
  add_index "hub_feeds", ["hub_id"], name: "index_hub_feeds_on_hub_id", using: :btree

  create_table "hubs", force: :cascade do |t|
    t.string   "title",       limit: 500,  null: false
    t.string   "description", limit: 2048
    t.string   "tag_prefix",  limit: 25
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "nickname",    limit: 255
    t.string   "slug",        limit: 255
  end

  add_index "hubs", ["slug"], name: "index_hubs_on_slug", using: :btree
  add_index "hubs", ["tag_prefix"], name: "index_hubs_on_tag_prefix", using: :btree
  add_index "hubs", ["title"], name: "index_hubs_on_title", using: :btree

  create_table "input_sources", force: :cascade do |t|
    t.integer  "republished_feed_id",                             null: false
    t.integer  "item_source_id",                                  null: false
    t.string   "item_source_type",    limit: 100,                 null: false
    t.string   "effect",              limit: 25,  default: "add", null: false
    t.integer  "limit"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "input_sources", ["effect"], name: "index_input_sources_on_effect", using: :btree
  add_index "input_sources", ["item_source_id"], name: "index_input_sources_on_item_source_id", using: :btree
  add_index "input_sources", ["item_source_type", "item_source_id", "effect", "republished_feed_id"], name: "bob_the_index", unique: true, using: :btree
  add_index "input_sources", ["republished_feed_id"], name: "index_input_sources_on_republished_feed_id", using: :btree

  create_table "republished_feeds", force: :cascade do |t|
    t.integer  "hub_id"
    t.string   "title",       limit: 500,               null: false
    t.string   "description", limit: 5120
    t.integer  "limit",                    default: 50
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "url_key",     limit: 50,                null: false
  end

  add_index "republished_feeds", ["hub_id"], name: "index_republished_feeds_on_hub_id", using: :btree
  add_index "republished_feeds", ["title"], name: "index_republished_feeds_on_title", using: :btree
  add_index "republished_feeds", ["url_key"], name: "index_republished_feeds_on_url_key", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",              limit: 40
    t.string   "authorizable_type", limit: 40
    t.integer  "authorizable_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "roles", ["authorizable_id"], name: "index_roles_on_authorizable_id", using: :btree
  add_index "roles", ["authorizable_type"], name: "index_roles_on_authorizable_type", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "roles_users", ["role_id"], name: "index_roles_users_on_role_id", using: :btree
  add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

  create_table "search_remixes", force: :cascade do |t|
    t.integer  "hub_id"
    t.text     "search_string"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "tag_filters", force: :cascade do |t|
    t.integer  "hub_id",                                 null: false
    t.integer  "tag_id",                                 null: false
    t.integer  "new_tag_id"
    t.integer  "scope_id"
    t.string   "scope_type", limit: 255
    t.boolean  "applied",                default: false
    t.string   "type",       limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "tag_filters", ["hub_id"], name: "index_tag_filters_on_hub_id", using: :btree
  add_index "tag_filters", ["new_tag_id"], name: "index_tag_filters_on_new_tag_id", using: :btree
  add_index "tag_filters", ["scope_type", "scope_id"], name: "index_tag_filters_on_scope_type_and_scope_id", using: :btree
  add_index "tag_filters", ["tag_id"], name: "index_tag_filters_on_tag_id", using: :btree
  add_index "tag_filters", ["type"], name: "index_tag_filters_on_type", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 255
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_type", "context"], name: "index_taggings_on_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 255
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 100
    t.string   "last_name",              limit: 100
    t.string   "url",                    limit: 250
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                    default: 0
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "username",               limit: 150
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
