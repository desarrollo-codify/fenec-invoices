class CreateVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :title
      t.decimal :price
      t.decimal :compare_price
      t.decimal :cost
      t.string :sku
      t.string :parent_sku
      t.string :barcode

      t.timestamps
    end
  end
end
