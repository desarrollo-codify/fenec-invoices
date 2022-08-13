# frozen_string_literal: true

class CreateMeasurements < ActiveRecord::Migration[7.0]
  def change
    create_table :measurements do |t|
      t.string :description

      t.timestamps
    end
  end
end
