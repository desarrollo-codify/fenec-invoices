class Country < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  def self.bulk_load(country)
    upsert_all(country, unique_by: :code)
  end
end
