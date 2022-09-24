class AddIsManualToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :is_manual, :boolean
  end
end
