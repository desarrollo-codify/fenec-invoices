class CreatePageOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :page_options do |t|
      t.string :code
      t.string :description
      t.references :page, null: false, foreign_key: true

      t.timestamps
    end
  end
end
