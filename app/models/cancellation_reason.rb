class CancellationReason < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  def self.bulk_load(reason)
    upsert_all(reason, unique_by: :code)
  end
end
