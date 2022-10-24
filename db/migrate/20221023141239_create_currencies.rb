class CreateCurrencies < ActiveRecord::Migration[7.0]
  def change
    create_table :currencies do |t|
      t.string :description
      t.string :abbreviation

      t.timestamps
    end
  end
end
