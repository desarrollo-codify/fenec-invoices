# frozen_string_literal: true

class CreateContingencies < ActiveRecord::Migration[7.0]
  def change
    create_table :contingencies do |t|
      t.datetime :start_date, null: false
      t.datetime :end_date
      t.references :branch_office, null: false, foreign_key: true
      t.references :significative_event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
