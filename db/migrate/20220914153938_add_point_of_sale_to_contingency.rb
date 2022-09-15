# frozen_string_literal: true

class AddPointOfSaleToContingency < ActiveRecord::Migration[7.0]
  def change
    add_reference :contingencies, :point_of_sale, null: false, foreign_key: true
  end
end
