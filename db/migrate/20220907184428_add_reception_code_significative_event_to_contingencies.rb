# frozen_string_literal: true

class AddReceptionCodeSignificativeEventToContingencies < ActiveRecord::Migration[7.0]
  def change
    add_column :contingencies, :reception_code_se, :string
    add_column :contingencies, :status, :string
  end
end
