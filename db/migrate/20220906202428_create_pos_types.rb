# frozen_string_literal: true

class CreatePosTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :pos_types do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :pos_types, :code, unique: true
  end
end
