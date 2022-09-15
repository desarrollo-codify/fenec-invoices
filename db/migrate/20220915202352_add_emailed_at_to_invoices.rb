# frozen_string_literal: true

class AddEmailedAtToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :emailed_at, :datetime
  end
end
