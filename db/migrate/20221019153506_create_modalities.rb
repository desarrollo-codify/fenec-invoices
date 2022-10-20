# frozen_string_literal: true

class CreateModalities < ActiveRecord::Migration[7.0]
  def change
    create_table :modalities do |t|
      t.string :description, null: false

      t.timestamps
    end
  end
end
