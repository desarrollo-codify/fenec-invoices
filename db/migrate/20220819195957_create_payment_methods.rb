# frozen_string_literal: true

class CreatePaymentMethods < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_methods do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :payment_methods, :code, unique: true
  end
end
