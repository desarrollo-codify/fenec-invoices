class CreateInvoiceLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :invoice_logs do |t|
      t.integer :code
      t.string :description
      t.references :invoice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
