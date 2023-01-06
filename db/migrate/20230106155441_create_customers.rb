class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :code
      t.string :name, null: false
      t.string :nit, null: false
      t.string :email
      t.string :phone
      t.string :complement
      t.references :document_type, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
