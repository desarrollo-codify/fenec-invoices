class ModifyCafcToInvoices < ActiveRecord::Migration[7.0]
  def change
    change_column :invoices, :cafc, :string
  end
end
