# frozen_string_literal: true

class RemoveClientsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :clients
  end
end
