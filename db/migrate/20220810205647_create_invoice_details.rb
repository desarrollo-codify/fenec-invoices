# frozen_string_literal: true

class CreateInvoiceDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :invoice_details do |t|
      t.string :description, null: false
      t.string :product_code
      t.decimal :unit_price, null: false
      t.decimal :quantity, null: false
      t.decimal :subtotal, null: false
      t.decimal :discount, null: false
      t.decimal :total, null: false
      t.references :measurement, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
