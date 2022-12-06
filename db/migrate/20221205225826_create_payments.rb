class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.decimal :mount, null: false
      t.references :payment_methods, null: false, foreign_key: true
      t.references :invoices, null: false, foreign_key: true

      t.timestamps
    end
  end
end
