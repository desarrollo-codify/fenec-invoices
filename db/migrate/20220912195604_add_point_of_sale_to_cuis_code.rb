class AddPointOfSaleToCuisCode < ActiveRecord::Migration[7.0]
  def change
    add_column :cuis_codes, :point_of_sale, :integer
  end
end
