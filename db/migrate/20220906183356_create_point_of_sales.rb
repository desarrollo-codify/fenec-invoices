# frozen_string_literal: true

class CreatePointOfSales < ActiveRecord::Migration[7.0]
  def change
    create_table :point_of_sales do |t|
      t.string :name, null: false
      t.integer :code, null: false
      t.string :description
      t.references :branch_office, null: false, foreign_key: true

      t.timestamps
    end
    add_index :point_of_sales, %i[branch_office_id code], unique: true
  end
end
