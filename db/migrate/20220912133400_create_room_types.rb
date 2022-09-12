class CreateRoomTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :room_types do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :room_types, :code, unique: true
  end
end
