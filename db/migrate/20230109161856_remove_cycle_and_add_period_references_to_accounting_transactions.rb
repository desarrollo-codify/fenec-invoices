# frozen_string_literal: true

class RemoveCycleAndAddPeriodReferencesToAccountingTransactions < ActiveRecord::Migration[7.0]
  def change
    remove_reference :accounting_transactions, :cycle
    add_reference :accounting_transactions, :period, foreign_key: true
  end
end
