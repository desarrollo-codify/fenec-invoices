# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :nit, null: false
      t.string :address, null: false
      t.string :phone
      t.string :logo

      t.timestamps
    end
    add_index :companies, :name, unique: true
  end
end
