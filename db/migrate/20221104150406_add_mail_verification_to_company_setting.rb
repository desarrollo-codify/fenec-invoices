# frozen_string_literal: true

class AddMailVerificationToCompanySetting < ActiveRecord::Migration[7.0]
  def change
    add_column :company_settings, :mail_verification, :boolean
  end
end
