# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.string :code
      t.string :name, null: false
      t.string :nit, null: false
      t.string :email
      t.string :phone
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
