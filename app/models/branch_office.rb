# frozen_string_literal: true

class BranchOffice < ApplicationRecord
  validates :name, presence: true, format: { with: VALID_NAME_REGEX }
  validates :city, presence: true, format: { with: VALID_CITY_REGEX }
  validates :number, presence: true, uniqueness: { scope: :company_id,
                                                   message: 'el numero de sucursal no puede duplicarse en una empresa.' }

  belongs_to :company
  has_many :daily_codes, dependent: :destroy
  has_many :invoices
  has_many :cuis_codes, dependent: :destroy

  def add_cuis_code!(code, expiration_date)
    cuis_codes.create(code: code, expiration_date: expiration_date) unless cuis_codes.find_by(code: code).present?
  end

  def add_daily_code!(code, effective_date)
    daily_codes.create(code: code, effective_date: effective_date)
  end
end
