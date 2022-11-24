# frozen_string_literal: true

class CreateOrderDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :order_details do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :product_id, limit: 8
      t.string :title
      t.string :sku
      t.decimal :total
      t.decimal :discount
      t.integer :quantity

      t.timestamps
    end
  end
end
