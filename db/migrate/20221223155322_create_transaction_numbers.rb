# frozen_string_literal: true

class CreateTransactionNumbers < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction_numbers do |t|
      t.integer :number
      t.references :cycle, null: false, foreign_key: true
      t.references :transaction_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
