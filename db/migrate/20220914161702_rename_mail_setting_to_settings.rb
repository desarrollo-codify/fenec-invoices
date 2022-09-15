# frozen_string_literal: true

class RenameMailSettingToSettings < ActiveRecord::Migration[7.0]
  def change
    rename_table :mail_settings, :company_settings
  end
end
