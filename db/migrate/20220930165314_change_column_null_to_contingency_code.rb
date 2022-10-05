# frozen_string_literal: true

class ChangeColumnNullToContingencyCode < ActiveRecord::Migration[7.0]
  def change
    change_column_null :contingency_codes, :available, true
  end
end
