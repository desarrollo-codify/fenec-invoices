# frozen_string_literal: true

class PosType < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  def self.bulk_load(pos_types)
    upsert_all(pos_types, unique_by: :code)
  end
end
