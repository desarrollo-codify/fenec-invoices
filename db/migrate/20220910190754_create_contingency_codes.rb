class CreateContingencyCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :contingency_codes do |t|
      t.string :code, null: false
      t.integer :document_sector_code, null: false
      t.integer :limit, null: false
      t.integer :current_use, null: false
      t.boolean :available, null: false
      t.references :economic_activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
