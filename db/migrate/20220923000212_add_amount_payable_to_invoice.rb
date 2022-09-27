# frozen_string_literal: true

class AddAmountPayableToInvoice < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :amount_payable, :decimal
  end
end
