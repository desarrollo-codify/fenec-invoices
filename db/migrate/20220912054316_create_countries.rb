class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :countries, :code, unique: true
  end
end
