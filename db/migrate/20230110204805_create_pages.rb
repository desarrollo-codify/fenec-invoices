class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.string :description
      t.references :system_module, null: false, foreign_key: true

      t.timestamps
    end
  end
end
