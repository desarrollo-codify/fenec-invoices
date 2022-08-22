class AddIndexToLegends < ActiveRecord::Migration[7.0]
  def change
    add_index :legends,  %i[economic_activity_id code], unique: true
  end
end
