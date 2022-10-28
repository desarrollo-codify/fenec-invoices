# frozen_string_literal: true

class CreateTransactionTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction_types do |t|
      t.string :description

      t.timestamps
    end
  end
end
