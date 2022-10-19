# frozen_string_literal: true

class CreateInvoiceTypesCompaniesJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :companies, :invoice_types
  end
end
