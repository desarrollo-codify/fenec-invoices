# frozen_string_literal: true

class AddTitleToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :title, :string
    add_reference :products, :product_type, index: false
    add_reference :products, :product_category, index: false
    add_reference :products, :product_status, index: false
  end
end
