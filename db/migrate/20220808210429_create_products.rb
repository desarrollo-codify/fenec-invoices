# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :primary_code, null: false
      t.string :description, null: false
      t.string :sin_code
      t.decimal :price
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
    add_index :products, %i[company_id primary_code], unique: true
  end
end
