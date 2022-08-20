class AddDataToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :municipality, :string, null: false
    add_column :invoices, :complement, :string
    add_column :invoices, :exception_code, :integer
    add_column :invoices, :currency_code, :integer, null: false
    add_column :invoices, :user, :string, null: false
    add_reference :invoices, :legends, null: false, foreign_key: true
    add_reference :invoices, :document_types, null: false, foreign_key: true
    add_reference :invoices, :payment_methods, null: false, foreign_key: true
  end
end
