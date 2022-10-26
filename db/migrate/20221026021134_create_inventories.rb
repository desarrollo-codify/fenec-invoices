class CreateInventories < ActiveRecord::Migration[7.0]
  def change
    create_table :inventories do |t|
      t.references :branch_office, null: false, foreign_key: true
      t.references :variant, null: false, foreign_key: true
      t.string :stock

      t.timestamps
    end
  end
end
