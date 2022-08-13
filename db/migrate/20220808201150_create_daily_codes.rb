# frozen_string_literal: true

class CreateDailyCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :daily_codes do |t|
      t.string :code, null: false
      t.datetime :effective_date, null: false
      t.string :control_code
      t.references :branch_office, null: false, foreign_key: true

      t.timestamps
    end
    add_index :daily_codes, %i[branch_office_id date], unique: true
  end
end
