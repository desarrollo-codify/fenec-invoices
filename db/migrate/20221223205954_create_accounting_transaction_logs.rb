# frozen_string_literal: true

class CreateAccountingTransactionLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :accounting_transaction_logs do |t|
      t.string :full_name
      t.string :action
      t.text :log_action
      t.references :accounting_transaction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
