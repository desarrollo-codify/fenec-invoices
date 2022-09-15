# frozen_string_literal: true

class RemoveBranchOfficeFromContingency < ActiveRecord::Migration[7.0]
  def change
    remove_reference :contingencies, :branch_office, null: false, foreign_key: true
  end
end
