# frozen_string_literal: true

class RemoveLogoFromCompany < ActiveRecord::Migration[7.0]
  def change
    remove_column :companies, :logo, :string
  end
end
