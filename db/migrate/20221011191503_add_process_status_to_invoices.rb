# frozen_string_literal: true

class AddProcessStatusToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :process_status, :string
  end
end
