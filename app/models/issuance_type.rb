class IssuanceType < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  def self.bulk_load(types)
    upsert_all(types, unique_by: :code)
  end
end
