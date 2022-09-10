# frozen_string_literal: true

class AddEndDateToDailyCode < ActiveRecord::Migration[7.0]
  def change
    add_column :daily_codes, :end_date, :datetime, null: false
  end
end
