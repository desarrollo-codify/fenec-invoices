# frozen_string_literal: true

class AddCancelSentAtToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :cancel_sent_at, :boolean
  end
end
