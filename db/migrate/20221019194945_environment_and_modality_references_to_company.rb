# frozen_string_literal: true

class EnvironmentAndModalityReferencesToCompany < ActiveRecord::Migration[7.0]
  def change
    add_reference :companies, :environment_type, foreign_key: true
    add_reference :companies, :modality, foreign_key: true
  end
end
