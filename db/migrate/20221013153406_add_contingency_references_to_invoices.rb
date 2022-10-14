# frozen_string_literal: true

class AddContingencyReferencesToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_reference :invoices, :contingency, foreign_key: true
  end
end
