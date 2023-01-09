# frozen_string_literal: true

class CreatePeriods < ActiveRecord::Migration[7.0]
  def change
    create_table :periods do |t|
      t.string :description, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date
      t.string :status, null: false
      t.references :cycle, null: false, foreign_key: true

      t.timestamps
    end
  end
end
