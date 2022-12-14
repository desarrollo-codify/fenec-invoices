# frozen_string_literal: true

class CreateCuisCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :cuis_codes do |t|
      t.string :code, null: false
      t.datetime :expiration_date, null: false
      t.integer :current_number, null: false
      t.references :branch_office, null: false, foreign_key: true

      t.timestamps
    end
  end
end
