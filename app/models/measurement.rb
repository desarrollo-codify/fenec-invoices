# frozen_string_literal: true

class Measurement < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }

  has_and_belongs_to_many :companies
  has_many :products

  def self.bulk_load(measurements)
    upsert_all(measurements)
  end
end
