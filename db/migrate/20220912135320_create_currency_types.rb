# frozen_string_literal: true

class CreateCurrencyTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :currency_types do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :currency_types, :code, unique: true
  end
end
