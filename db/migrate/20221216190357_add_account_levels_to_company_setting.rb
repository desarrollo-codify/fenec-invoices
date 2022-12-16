class AddAccountLevelsToCompanySetting < ActiveRecord::Migration[7.0]
  def change
    add_column :company_settings, :account_levels, :integer, default: 4
  end
end
