# frozen_string_literal: true

class CreateContingencyLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :contingency_logs do |t|
      t.integer :code
      t.string :description
      t.references :contingency, null: false, foreign_key: true

      t.timestamps
    end
  end
end
