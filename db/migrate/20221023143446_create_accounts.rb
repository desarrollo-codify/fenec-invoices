class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :number
      t.string :description
      t.decimal :amount
      t.decimal :percentage
      t.references :company, null: false, foreign_key: true
      t.references :cycle, null: false, foreign_key: true
      t.references :account_type, null: false, foreign_key: true
      t.references :account_level, null: false, foreign_key: true

      t.timestamps
    end
  end
end
