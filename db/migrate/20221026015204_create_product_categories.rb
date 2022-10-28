# frozen_string_literal: true

class CreateProductCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :product_categories do |t|
      t.string :description

      t.timestamps
    end
  end
end
