# frozen_string_literal: true

class CreateOrderCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :order_customers do |t|
      t.references :order, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.integer :customer_id, limit: 8

      t.timestamps
    end
  end
end
