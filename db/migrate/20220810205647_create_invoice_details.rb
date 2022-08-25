# frozen_string_literal: true

class CreateInvoiceDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :invoice_details do |t|
      t.integer :economic_activity_code, null: false
      t.integer :sin_code, null: false
      t.string :product_code, null: false
      t.string :description, null: false
      t.decimal :quantity, null: false
      t.decimal :unit_price, null: false
      t.decimal :subtotal, null: false
      t.decimal :discount, null: false
      t.decimal :total, null: false
      t.string :serial_number
      t.string :imei_code
      t.references :measurement, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
