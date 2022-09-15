class RemoveColumnNullConstraintFromInvoiceDetail < ActiveRecord::Migration[7.0]
  def change
    change_column_null :invoice_details, :sin_code, true
  end
end
