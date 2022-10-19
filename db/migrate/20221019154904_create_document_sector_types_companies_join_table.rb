# frozen_string_literal: true

class CreateDocumentSectorTypesCompaniesJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :companies, :document_sector_types
  end
end
