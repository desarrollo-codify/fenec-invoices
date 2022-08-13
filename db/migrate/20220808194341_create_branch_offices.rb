# frozen_string_literal: true

class CreateBranchOffices < ActiveRecord::Migration[7.0]
  def change
    create_table :branch_offices do |t|
      t.string :name, null: false
      t.string :phone
      t.string :address
      t.string :city, null: false
      t.integer :number, null: false
      t.string :cuis_number
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
    add_index :branch_offices, %i[company_id number], unique: true
  end
end
