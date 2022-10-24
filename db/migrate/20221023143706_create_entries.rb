class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :entries do |t|
      t.decimal :debit_bs
      t.decimal :credit_bs
      t.decimal :debit_sus
      t.decimal :credit_sus
      t.references :accounting_transaction, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
