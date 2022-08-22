# frozen_string_literal: true

class AddCurrentNumberToCuisCodes < ActiveRecord::Migration[7.0]
  def change
    add_column :cuis_codes, :current_number, :integer
  end
end
