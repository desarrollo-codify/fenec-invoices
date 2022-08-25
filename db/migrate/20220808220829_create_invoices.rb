# frozen_string_literal: true

class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.string :company_nit, null: false
      t.string :company_name, null: false
      t.string :municipality, null: false
      t.string :phone
      t.integer :number
      t.string :cuf
      t.string :cufd_code, null: false
      t.string :control_code
      t.integer :branch_office_number
      t.string :address, null: false
      t.integer :point_of_sale
      t.datetime :date, null: false
      t.string :business_name, null: false
      t.integer :document_type, null: false
      t.string :business_nit, null: false
      t.string :complement
      t.string :client_code, null: false
      t.integer :payment_method, null: false
      t.string :card_number
      t.decimal :subtotal, null: false
      t.decimal :total, null: false
      t.decimal :gift_card_total
      t.decimal :discount
      t.integer :exception_code
      t.integer :cafc
      t.integer :currency_code, null: false
      t.decimal :exchange_rate, null: false
      t.decimal :currency_total, null: false
      t.string :legend, null: false
      t.string :user, null: false
      t.integer :document_sector_code, null: false
      # pending to check
      t.datetime :cancellation_date
      t.string :qr_content
      t.decimal :gift_card
      t.decimal :advance
      t.decimal :cash_paid
      t.decimal :qr_paid
      t.decimal :card_paid
      t.decimal :online_paid
      t.references :branch_office, null: false, foreign_key: true
      t.references :invoice_status, null: false, foreign_key: true
      t.timestamps
    end
    add_index :invoices, %i[number cufd_code], unique: true
  end
end
