# frozen_string_literal: true

class BranchOffice < ApplicationRecord
  validates :name, presence: true, format: { with: VALID_NAME_REGEX }
  validates :city, presence: true, format: { with: VALID_CITY_REGEX }
  validates :number, presence: true, uniqueness: { scope: :company_id,
                                                   message: 'el numero de sucursal no puede duplicarse en una empresa.' }

  belongs_to :company
  has_many :daily_codes, dependent: :destroy
  has_many :invoices
end
