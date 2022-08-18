class RemoveCuisNumberFromBranchOffices < ActiveRecord::Migration[7.0]
  def change
    remove_column :branch_offices, :cuis_number, :string
  end
end
