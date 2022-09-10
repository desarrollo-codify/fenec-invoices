# frozen_string_literal: true

class ChangesReceptionCodeSeToContingencies < ActiveRecord::Migration[7.0]
  def change
    rename_column :contingencies, :reception_code_se, :event_reception_code
  end
end
