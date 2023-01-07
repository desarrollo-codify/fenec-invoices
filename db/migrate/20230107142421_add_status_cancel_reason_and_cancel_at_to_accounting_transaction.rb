# frozen_string_literal: true

class AddStatusCancelReasonAndCancelAtToAccountingTransaction < ActiveRecord::Migration[7.0]
  def change
    add_column :accounting_transactions, :status, :integer
    add_column :accounting_transactions, :cancelletion_reason, :string
    add_column :accounting_transactions, :canceled_at, :datetime
  end
end
