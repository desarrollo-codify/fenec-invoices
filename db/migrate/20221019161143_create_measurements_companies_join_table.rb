# frozen_string_literal: true

class CreateMeasurementsCompaniesJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :companies, :measurements
  end
end
