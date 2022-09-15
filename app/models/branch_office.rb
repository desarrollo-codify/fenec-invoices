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
  has_many :point_of_sales, dependent: :destroy

  def add_cuis_code!(code, expiration_date, point_of_sale)
    unless cuis_codes.find_by(code: code).present?
      cuis_codes.create(code: code, expiration_date: expiration_date,
                        point_of_sale: point_of_sale)
    end
  end

  def add_daily_code!(code, control_code, effective_date, end_date, point_of_sale)
    daily_code = daily_codes.find_by(effective_date: effective_date.beginning_of_day..effective_date.end_of_day,
                                     point_of_sale: point_of_sale)

    if daily_code
      daily_code.update(code: code, control_code: control_code, end_date: end_date, point_of_sale: point_of_sale)
    else
      daily_codes.create(code: code, control_code: control_code, effective_date: effective_date, end_date: end_date,
                         point_of_sale: point_of_sale)
    end
  end

  def create_contingency
    contingencies.create(start_date: DateTime.now, significative_event_id: 2)
  end
end
