class CreateServiceMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :service_messages do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :service_messages, :code, unique: true
  end
end
