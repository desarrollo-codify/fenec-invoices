# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  has_many :invoices

  def self.bulk_load(activities)
    upsert_all(activities, unique_by: :code)
  end
end
