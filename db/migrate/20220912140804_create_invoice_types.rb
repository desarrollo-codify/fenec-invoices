class CreateInvoiceTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :invoice_types do |t|
      t.integer :code, null: false
      t.string :description, null: false

      t.timestamps
    end
    add_index :invoice_types, :code, unique: true
  end
end
