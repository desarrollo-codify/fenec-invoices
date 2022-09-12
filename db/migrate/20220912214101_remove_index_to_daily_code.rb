class RemoveIndexToDailyCode < ActiveRecord::Migration[7.0]
  def change
    remove_index :daily_codes, %i[branch_office_id effective_date]
  end
end
