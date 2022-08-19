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

ActiveRecord::Schema[7.0].define(version: 2022_08_18_194942) do
  create_table "branch_offices", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.string "address"
    t.string "city", null: false
    t.integer "number", null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "number"], name: "index_branch_offices_on_company_id_and_number", unique: true
    t.index ["company_id"], name: "index_branch_offices_on_company_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "code"
    t.string "name", null: false
    t.string "nit", null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_clients_on_company_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "nit", null: false
    t.string "address", null: false
    t.string "phone"
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "cuis_codes", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "expiration_date", null: false
    t.integer "branch_office_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_office_id"], name: "index_cuis_codes_on_branch_office_id"
  end

  create_table "daily_codes", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "effective_date", null: false
    t.string "control_code"
    t.integer "branch_office_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_office_id", "effective_date"], name: "index_daily_codes_on_branch_office_id_and_effective_date", unique: true
    t.index ["branch_office_id"], name: "index_daily_codes_on_branch_office_id"
  end

  create_table "delegated_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.string "expiration_date", null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_delegated_tokens_on_company_id"
  end

  create_table "economic_activities", force: :cascade do |t|
    t.integer "code", null: false
    t.string "description", null: false
    t.string "activity_type"
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "code"], name: "index_economic_activities_on_company_id_and_code", unique: true
    t.index ["company_id"], name: "index_economic_activities_on_company_id"
  end

  create_table "invoice_details", force: :cascade do |t|
    t.string "description", null: false
    t.string "product_code"
    t.decimal "unit_price", null: false
    t.decimal "quantity", null: false
    t.decimal "subtotal", null: false
    t.decimal "discount", null: false
    t.decimal "total", null: false
    t.integer "measurement_id", null: false
    t.integer "product_id", null: false
    t.integer "invoice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_details_on_invoice_id"
    t.index ["measurement_id"], name: "index_invoice_details_on_measurement_id"
    t.index ["product_id"], name: "index_invoice_details_on_product_id"
  end

  create_table "invoice_statuses", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "number"
    t.datetime "date", null: false
    t.string "company_name"
    t.string "company_nit"
    t.string "business_name", null: false
    t.string "business_nit", null: false
    t.string "authorization"
    t.string "key"
    t.datetime "end_date"
    t.string "activity_type"
    t.string "control_code"
    t.string "qr_content"
    t.decimal "subtotal", null: false
    t.decimal "discount"
    t.decimal "gift_card"
    t.decimal "advance"
    t.decimal "total", null: false
    t.decimal "cash_paid"
    t.decimal "qr_paid"
    t.decimal "card_paid"
    t.decimal "online_paid"
    t.decimal "change"
    t.datetime "cancellation_date"
    t.decimal "exchange_rate"
    t.string "cuis_code"
    t.string "cufd_code"
    t.integer "branch_office_id", null: false
    t.integer "invoice_status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_office_id"], name: "index_invoices_on_branch_office_id"
    t.index ["invoice_status_id"], name: "index_invoices_on_invoice_status_id"
    t.index ["number", "cufd_code"], name: "index_invoices_on_number_and_cufd_code", unique: true
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "measurements", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_channels", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "primary_code", null: false
    t.string "description", null: false
    t.string "sin_code"
    t.decimal "price"
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "primary_code"], name: "index_products_on_company_id_and_primary_code", unique: true
    t.index ["company_id"], name: "index_products_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "branch_offices", "companies"
  add_foreign_key "clients", "companies"
  add_foreign_key "cuis_codes", "branch_offices"
  add_foreign_key "daily_codes", "branch_offices"
  add_foreign_key "delegated_tokens", "companies"
  add_foreign_key "economic_activities", "companies"
  add_foreign_key "invoice_details", "invoices"
  add_foreign_key "invoice_details", "measurements"
  add_foreign_key "invoice_details", "products"
  add_foreign_key "invoices", "branch_offices"
  add_foreign_key "invoices", "invoice_statuses"
  add_foreign_key "products", "companies"
end
