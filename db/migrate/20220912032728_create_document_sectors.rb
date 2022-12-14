# frozen_string_literal: true

class CreateDocumentSectors < ActiveRecord::Migration[7.0]
  def change
    create_table :document_sectors do |t|
      t.integer :code, null: false
      t.string :description, null: false
      t.references :economic_activity, null: false, foreign_key: true

      t.timestamps
    end
    add_index :document_sectors, %i[economic_activity_id code], unique: true
  end
end
