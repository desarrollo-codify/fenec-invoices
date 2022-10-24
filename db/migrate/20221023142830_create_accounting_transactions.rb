class CreateAccountingTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :accounting_transactions do |t|
      t.date :date
      t.integer :number
      t.string :receipt
      t.text :gloss
      t.integer :type
      t.references :currency, null: false, foreign_key: true
      t.references :cycle, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.references :transaction_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
