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

ActiveRecord::Schema.define(version: 20181204070359) do

  create_table "bills", force: true do |t|
    t.string   "version"
    t.datetime "issue_at"
    t.string   "engrave_year"
    t.string   "face_value"
    t.string   "pack_spec"
    t.string   "head"
    t.string   "tail"
    t.string   "prefix"
    t.string   "serial_no"
    t.string   "watermark"
    t.string   "print_process"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coins", force: true do |t|
    t.string   "theme"
    t.string   "issue_unit"
    t.string   "circulation"
    t.string   "material"
    t.string   "weight"
    t.string   "year"
    t.string   "face_value"
    t.string   "pack_spec"
    t.string   "cast_unit"
    t.string   "diameter"
    t.string   "percentage"
    t.string   "quality"
    t.string   "shape"
    t.string   "head"
    t.string   "tail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commodities", force: true do |t|
    t.string   "no",                         null: false
    t.string   "name",                       null: false
    t.string   "short_name"
    t.string   "common_name"
    t.integer  "catalog_id",                 null: false
    t.string   "category",                   null: false
    t.boolean  "is_show",     default: true
    t.string   "pic_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "detail_id"
    t.string   "detail_type"
  end

  add_index "commodities", ["detail_type", "detail_id"], name: "index_commodities_on_detail_type_and_detail_id"

  create_table "front_users", force: true do |t|
    t.string   "name"
    t.string   "nickname"
    t.integer  "phone"
    t.string   "status",      default: "unauthen", null: false
    t.string   "authen_code"
    t.string   "wechat_id",                        null: false
    t.string   "email"
    t.string   "head_url",                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", force: true do |t|
    t.string   "module_name"
    t.string   "operation"
    t.boolean  "is_show",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stamps", force: true do |t|
    t.string   "serial_no"
    t.string   "format"
    t.string   "theme"
    t.string   "version"
    t.string   "designer"
    t.string   "ori_author"
    t.string   "engrave_author"
    t.datetime "issue_at"
    t.string   "issue_unit"
    t.string   "print_unit"
    t.string   "gum"
    t.string   "circulation"
    t.string   "set_amount"
    t.string   "page_amount"
    t.string   "perforation"
    t.string   "specification"
    t.string   "editor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_logs", force: true do |t|
    t.integer  "user_id",            default: 0,  null: false
    t.string   "operation",          default: "", null: false
    t.string   "object_class"
    t.integer  "object_primary_key"
    t.string   "object_symbol"
    t.string   "desc"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_permissions", force: true do |t|
    t.integer  "user_id"
    t.integer  "permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",         null: false
    t.string   "encrypted_password",     default: "pwd12345", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,          null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username",               default: "",         null: false
    t.string   "name"
    t.datetime "locked_at"
    t.integer  "failed_attempts",        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
