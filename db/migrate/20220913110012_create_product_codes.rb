# frozen_string_literal: true

class CreateProductCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :product_codes do |t|
      t.integer :code, null: false
      t.string :description, null: false
      t.references :economic_activity, null: false, foreign_key: true

      t.timestamps
    end
    add_index :product_codes, %i[economic_activity_id code], unique: true
  end
end
