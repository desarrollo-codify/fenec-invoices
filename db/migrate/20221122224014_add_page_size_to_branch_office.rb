# frozen_string_literal: true

class AddPageSizeToBranchOffice < ActiveRecord::Migration[7.0]
  def change
    add_reference :branch_offices, :page_size, foreign_key: true
  end
end
