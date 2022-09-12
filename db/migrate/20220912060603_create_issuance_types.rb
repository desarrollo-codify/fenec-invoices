# frozen_string_literal: true

class CreateIssuanceTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :issuance_types do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :issuance_types, :code, unique: true
  end
end
