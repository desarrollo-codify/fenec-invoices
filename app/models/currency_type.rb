# frozen_string_literal: true

class CurrencyType < ApplicationRecord
  validates :code, presence: { message: 'El código no puede estar en blanco.' }, uniqueness: true
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }, format: { with: VALID_NAME_REGEX }

  def self.bulk_load(types)
    upsert_all(types, unique_by: :code)
  end
end
