class AddEconomicActivityToInvoiceDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :invoice_details, :economic_activity, :string
  end
end
