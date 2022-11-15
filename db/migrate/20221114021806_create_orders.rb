class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.integer :order_id, limit: 8
      t.integer :number
      t.datetime :date
      t.decimal :total_discount
      t.integer :location_id, limit: 8
      t.references :company, null: false, foreign_key: true
      t.references :invoice, foreign_key: true

      t.timestamps
    end
  end
end
