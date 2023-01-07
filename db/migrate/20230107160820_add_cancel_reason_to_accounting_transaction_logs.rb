# frozen_string_literal: true

class AddCancelReasonToAccountingTransactionLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :accounting_transaction_logs, :cancellation_reason, :string
  end
end
