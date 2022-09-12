# frozen_string_literal: true

class AddSentAtToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :sent_at, :string, null: true
  end
end
