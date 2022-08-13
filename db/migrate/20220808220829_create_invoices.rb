class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.integer :number
      t.datetime :date, null: false
      t.string :company_name
      t.string :company_nit
      t.string :business_name, null: false
      t.string :business_nit, null: false
      t.string :authorization
      t.string :key
      t.datetime :end_date
      t.string :activity_type
      t.string :control_code
      t.string :qr_content
      t.decimal :subtotal, null: false
      t.decimal :discount
      t.decimal :gift_card
      t.decimal :advance
      t.decimal :total, null: false
      t.decimal :cash_paid
      t.decimal :qr_paid
      t.decimal :card_paid
      t.decimal :online_paid
      t.decimal :change
      t.datetime :cancellation_date
      t.decimal :exchange_rate
      t.string :cuis_code
      t.string :cufd_code
      t.references :branch_office, null: false, foreign_key: true
      t.references :invoice_status, null: false, foreign_key: true

      t.timestamps
    end
    add_index :invoices, [:number, :cufd_code], unique: true
  end
end
