# frozen_string_literal: true

class CreateDelegatedTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :delegated_tokens do |t|
      t.string :token, null: false
      t.string :expiration_date, null: false
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
