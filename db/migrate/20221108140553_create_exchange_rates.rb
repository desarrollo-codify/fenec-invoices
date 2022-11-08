# frozen_string_literal: true

class CreateExchangeRates < ActiveRecord::Migration[7.0]
  def change
    create_table :exchange_rates do |t|
      t.date :date
      t.decimal :rate
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
