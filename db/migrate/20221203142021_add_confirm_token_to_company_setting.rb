# frozen_string_literal: true

class AddConfirmTokenToCompanySetting < ActiveRecord::Migration[7.0]
  def change
    add_column :company_settings, :confirm_token, :string
  end
end
