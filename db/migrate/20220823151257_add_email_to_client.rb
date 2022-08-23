# frozen_string_literal: true

class AddEmailAndPhoneToClient < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :email, :string
    add_column :clients, :phone, :string
  end
end
