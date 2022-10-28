# frozen_string_literal: true

class AddBrandToProduct < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :brand, foreign_key: true
  end
end
