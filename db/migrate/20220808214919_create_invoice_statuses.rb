class CreateInvoiceStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :invoice_statuses do |t|
      t.string :description

      t.timestamps
    end
  end
end
