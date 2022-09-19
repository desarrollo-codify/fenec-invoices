# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  has_and_belongs_to_many :invoices
  
  def self.bulk_load(payment_methods)
    upsert_all(payment_methods, unique_by: :code)
  end
end
