# frozen_string_literal: true

class CreateEconomicActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :economic_activities do |t|
      t.integer :code, null: false
      t.string :description, null: false
      t.string :activity_type
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
