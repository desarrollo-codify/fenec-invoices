# frozen_string_literal: true

class CreateMailSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :mail_settings do |t|
      t.string :address, null: false
      t.integer :port, null: false
      t.string :domain, null: false
      t.string :user_name, null: false
      t.string :password, null: false
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
