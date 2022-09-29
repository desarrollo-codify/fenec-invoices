# frozen_string_literal: true

class DailyCode < ApplicationRecord
  validates :code, presence: true
  validates :effective_date, presence: true, uniqueness: { scope: :point_of_sale,
                                                           message: 'Solo puede ser un codigo diario por punto de venta.' }
  validate :date_cannot_be_lower_than_last_one
  validates :end_date, presence: true

  belongs_to :branch_office

  scope :current, -> { where('end_date >= ?', DateTime.now).last }
  scope :by_date, ->(date) { where('? BETWEEN effective_date AND end_date ', date) }

  private

  def date_cannot_be_lower_than_last_one
    last_daily_code = DailyCode.where(branch_office_id: branch_office_id, point_of_sale: point_of_sale).last
    return unless last_daily_code

    return unless end_date < last_daily_code.end_date

    errors.add(:end_date, 'No se puede registrar una fecha anterior al último registro.')
  end
end
