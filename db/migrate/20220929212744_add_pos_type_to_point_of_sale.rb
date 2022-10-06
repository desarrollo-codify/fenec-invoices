# frozen_string_literal: true

class AddPosTypeToPointOfSale < ActiveRecord::Migration[7.0]
  def change
    add_reference :point_of_sales, :pos_type, foreign_key: true
  end
end
