# frozen_string_literal: true

class AddInvoicesToContingency < ActiveRecord::Migration[7.0]
  def change
    add_reference :contingencies, :invoices, foreign_key: true
  end
end
