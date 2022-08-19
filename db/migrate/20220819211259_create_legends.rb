# frozen_string_literal: true

class CreateLegends < ActiveRecord::Migration[7.0]
  def change
    create_table :legends do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end
