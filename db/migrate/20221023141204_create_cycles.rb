# frozen_string_literal: true

class CreateCycles < ActiveRecord::Migration[7.0]
  def change
    create_table :cycles do |t|
      t.integer :year
      t.string :status
      t.date :start_date
      t.date :end_date
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
