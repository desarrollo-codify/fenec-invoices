class CreateMeasurementTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :measurement_types do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end
