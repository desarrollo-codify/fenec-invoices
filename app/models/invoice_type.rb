# frozen_string_literal: true

class InvoiceType < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  has_and_belongs_to_many :companies

  def self.bulk_load(types)
    upsert_all(types, unique_by: :code)
  end
end
