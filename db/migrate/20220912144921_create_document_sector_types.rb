# frozen_string_literal: true

class CreateDocumentSectorTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :document_sector_types do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :document_sector_types, :code, unique: true
  end
end
