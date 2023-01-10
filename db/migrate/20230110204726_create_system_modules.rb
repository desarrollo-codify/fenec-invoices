class CreateSystemModules < ActiveRecord::Migration[7.0]
  def change
    create_table :system_modules do |t|
      t.string :description

      t.timestamps
    end
  end
end
