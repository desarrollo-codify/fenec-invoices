# frozen_string_literal: true

class AddIsSecureToCompanySetting < ActiveRecord::Migration[7.0]
  def change
    add_column :company_settings, :is_secure, :boolean
  end
end
