# frozen_string_literal: true

class ChangeDescriptionToBeTextInProduct < ActiveRecord::Migration[7.0]
  def up
    change_column :products, :description, :text
  end

  def down
    change_column :products, :description, :string
  end
end
