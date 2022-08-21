class AddDataToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :municipality, :string, null: false
    add_column :invoices, :phone, :string, null: false
    add_column :invoices, :address, :string, null: false
    add_column :invoices, :point_of_sale, :integer
    add_column :invoices, :document_type, :integer
    add_column :invoices, :complement, :string
    add_column :invoices, :client_code, :string
    add_column :invoices, :payment_method, :integer
    add_column :invoices, :card_number, :string
    add_column :invoices, :gift_card_total, :decimal
    add_column :invoices, :currency_total, :decimal
    add_column :invoices, :currency_code, :integer, null: false
    add_column :invoices, :exception_code, :integer
    add_column :invoices, :cafc, :integer
    add_column :invoices, :legend, :string
    add_column :invoices, :user, :string
    add_column :invoices, :document_sector_code, :integer
  end
end
