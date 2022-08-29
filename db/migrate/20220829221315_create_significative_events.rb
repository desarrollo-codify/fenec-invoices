class CreateSignificativeEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :significative_events do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :significative_events, :code, unique: true
  end
end
