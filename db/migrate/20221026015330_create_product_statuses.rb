class CreateProductStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :product_statuses do |t|
      t.string :description

      t.timestamps
    end
  end
end
