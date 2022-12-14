# frozen_string_literal: true

class RemovePaymentsMethodsToInvoices < ActiveRecord::Migration[7.0]
  def change
    remove_column :invoices, :cash_paid, :decimal
    remove_column :invoices, :qr_paid, :decimal
    remove_column :invoices, :card_paid, :decimal
    remove_column :invoices, :online_paid, :decimal
    remove_column :invoices, :gift_card, :decimal
  end
end
