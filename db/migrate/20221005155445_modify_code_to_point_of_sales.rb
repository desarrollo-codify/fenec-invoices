class ModifyCodeToPointOfSales < ActiveRecord::Migration[7.0]
  def change
    change_column_null :point_of_sales, :code, true
  end
end