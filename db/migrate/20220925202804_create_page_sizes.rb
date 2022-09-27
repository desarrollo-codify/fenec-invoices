# frozen_string_literal: true

class CreatePageSizes < ActiveRecord::Migration[7.0]
  def change
    create_table :page_sizes do |t|
      t.string :description, null: false

      t.timestamps
    end
  end
end
