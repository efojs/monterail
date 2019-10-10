# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_10_181211) do

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.datetime "start_at"
    t.integer "tickets_total"
    t.integer "tickets_sold"
    t.decimal "ticket_price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "end_at"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "tickets_amount", null: false
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "expires_at", precision: 6, null: false
    t.decimal "sum", default: "0.0"
    t.index ["event_id"], name: "index_orders_on_event_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "order_id", null: false
    t.string "key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_tickets_on_order_id"
  end

  add_foreign_key "orders", "events"
  add_foreign_key "tickets", "orders"
end
