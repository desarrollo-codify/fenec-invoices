class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.string :code
      t.string :name, null: false
      t.string :nit, null: false

      t.timestamps
    end
  end
end
