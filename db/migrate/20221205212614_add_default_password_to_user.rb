class AddDefaultPasswordToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :default_password, :boolean
  end
end
