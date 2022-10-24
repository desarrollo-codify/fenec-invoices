class CreateAccountLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :account_levels do |t|
      t.string :description
      t.string :initial

      t.timestamps
    end
  end
end
