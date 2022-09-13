# frozen_string_literal: true

class AddDocumentTypeIdAndComplementToClient < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :complement, :string
    add_reference :clients, :document_type, foreign_key: true
  end
end
