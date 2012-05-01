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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120501170146) do

  create_table "accounts", :force => true do |t|
    t.string   "email_address", :null => false
    t.integer  "provider_id",   :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "accounts", ["email_address"], :name => "index_accounts_on_email_address", :unique => true

  create_table "mailboxes", :force => true do |t|
    t.string  "name",       :null => false
    t.string  "delimiter",  :null => false
    t.string  "flag_attr"
    t.integer "account_id", :null => false
  end

  add_index "mailboxes", ["account_id"], :name => "index_mailboxes_on_account_id"
  add_index "mailboxes", ["name"], :name => "index_mailboxes_on_name"

  create_table "providers", :force => true do |t|
    t.string  "name",                           :null => false
    t.string  "imap_address",                   :null => false
    t.integer "imap_port",    :default => 993
    t.boolean "imap_ssl",     :default => true
  end

end
