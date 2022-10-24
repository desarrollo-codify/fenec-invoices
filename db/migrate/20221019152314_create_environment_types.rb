# frozen_string_literal: true

class CreateEnvironmentTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :environment_types do |t|
      t.string :description, null: false

      t.timestamps
    end
  end
end
