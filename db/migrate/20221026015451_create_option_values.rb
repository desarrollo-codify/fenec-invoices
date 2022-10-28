# frozen_string_literal: true

class CreateOptionValues < ActiveRecord::Migration[7.0]
  def change
    create_table :option_values do |t|
      t.references :option, null: false, foreign_key: true
      t.string :description

      t.timestamps
    end
  end
end
