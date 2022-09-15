# frozen_string_literal: true

class AddFieldsToCompanySetting < ActiveRecord::Migration[7.0]
  def change
    add_column :company_settings, :system_code, :string
    add_column :company_settings, :api_key, :string
  end
end
