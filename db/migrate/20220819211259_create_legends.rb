# frozen_string_literal: true

class CreateLegends < ActiveRecord::Migration[7.0]
  def change
    create_table :legends do |t|
      t.integer :code, null: false
      t.string :description, null: false
      t.references :economic_activity, null: false, foreign_key: true

      t.timestamps
      add_index :economic_activities, %i[economic_activity_id code], unique: true
    end
  end
end
