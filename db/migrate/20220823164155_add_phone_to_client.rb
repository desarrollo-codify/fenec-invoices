class AddPhoneToClient < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :phone, :string
  end
end
