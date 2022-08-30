# frozen_string_literal: true

class SignificativeEvent < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  def self.bulk_load(events)
    upsert_all(events, unique_by: :code)
  end
end