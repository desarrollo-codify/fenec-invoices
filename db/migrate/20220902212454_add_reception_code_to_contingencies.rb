class AddReceptionCodeToContingencies < ActiveRecord::Migration[7.0]
  def change
    add_column :contingencies, :reception_code, :string
  end
end
