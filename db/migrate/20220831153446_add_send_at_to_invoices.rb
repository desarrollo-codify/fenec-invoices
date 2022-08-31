class AddSendAtToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :send_at, :string, :null => true
  end
end
