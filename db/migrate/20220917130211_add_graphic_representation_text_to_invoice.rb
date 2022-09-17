# frozen_string_literal: true

class AddGraphicRepresentationTextToInvoice < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :graphic_representation_text, :string
  end
end
