# frozen_string_literal: true

class AddPointOfSaleToDailyCode < ActiveRecord::Migration[7.0]
  def change
    add_column :daily_codes, :point_of_sale, :integer
  end
end
