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
  has_many :contingencies, through: :point_of_sales

  after_create :add_point_of_sale

  def add_cuis_code!(code, expiration_date, point_of_sale)
    return if cuis_codes.find_by(code: code).present?
    
    cuis_codes.create(code: code, expiration_date: expiration_date,
      point_of_sale: point_of_sale)
  end
    
  def add_daily_code!(code, control_code, effective_date, end_date, point_of_sale)
    daily_codes.create(code: code, control_code: control_code, effective_date: effective_date, end_date: end_date,
      point_of_sale: point_of_sale)
  end
      
  def create_contingency
    contingencies.create(start_date: DateTime.now, significative_event_id: 2)
  end
      
  def add_point_of_sales!(pos_list)
    point_of_sales.upsert_all(pos_list, unique_by: %i[branch_office_id code])
  end

  private

  def add_point_of_sale
    point_of_sales.create(name: 'POS-0', code: 0)
  end
end
