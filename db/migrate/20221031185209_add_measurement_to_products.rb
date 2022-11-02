# frozen_string_literal: true

class AddMeasurementToProducts < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :measurement, foreign_key: true
  end
end
