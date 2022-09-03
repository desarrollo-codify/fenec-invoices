class CreateCancellationReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :cancellation_reasons do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :cancellation_reasons, :code, unique: true
  end
end
