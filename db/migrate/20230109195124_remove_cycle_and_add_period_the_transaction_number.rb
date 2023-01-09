# frozen_string_literal: true

class RemoveCycleAndAddPeriodTheTransactionNumber < ActiveRecord::Migration[7.0]
  def change
    remove_reference :transaction_numbers, :cycle
    add_reference :transaction_numbers, :period, foreign_key: true
  end
end
