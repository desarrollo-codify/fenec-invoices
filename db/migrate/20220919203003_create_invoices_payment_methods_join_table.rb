# frozen_string_literal: true

class CreateInvoicesPaymentMethodsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :invoices, :payment_methods
  end
end
