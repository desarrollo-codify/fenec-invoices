class CreateInvoiceDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :invoice_details do |t|
      t.string :description
      t.string :product_code
      t.decimal :unit_price
      t.decimal :quantity
      t.decimal :subtotal
      t.decimal :discount
      t.decimal :total
      t.references :measurement, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
