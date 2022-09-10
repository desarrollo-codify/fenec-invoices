# frozen_string_literal: true

class CancellationReasonToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_reference :invoices, :cancellation_reason, index: true
  end
end
