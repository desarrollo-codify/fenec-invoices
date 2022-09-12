# frozen_string_literal: true

class Country < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  def self.bulk_load(countries)
    upsert_all(countries, unique_by: :code)
  end
end
