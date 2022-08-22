# frozen_string_literal: true

class AddEconomicActivityToInvoiceDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :invoice_details, :economic_activity_code, :integer
    add_column :invoice_details, :sin_code, :integer
    add_column :invoice_details, :serial_number, :string
    add_column :invoice_details, :imei_code, :string
  end
end
