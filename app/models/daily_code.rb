# frozen_string_literal: true

class DailyCode < ApplicationRecord
  validates :code, presence: { message: 'El código no puede estar en blanco.' }
  validates :effective_date, presence: { message: 'La fecha de vigencia no puede estar en blanco.' },
                             uniqueness: { scope: :point_of_sale,
                                           message: 'Solo puede ser un codigo diario por punto de venta.' }
  validate :date_cannot_be_lower_than_last_one
  validates :end_date, presence: { message: 'La fecha de caducidad no puede estar en blanco.' }

  belongs_to :branch_office

  scope :active, -> { where('end_date >= ?', DateTime.now) }
  scope :by_date, ->(date) { where('? BETWEEN effective_date AND end_date ', date.to_datetime) }
  scope :by_pos, ->(point_of_sale) { where(point_of_sale: point_of_sale) }

  def self.current
    active.last
  end

  private

  def date_cannot_be_lower_than_last_one
    last_daily_code = DailyCode.where(branch_office_id: branch_office_id, point_of_sale: point_of_sale).last
    return unless last_daily_code

    return unless end_date < last_daily_code.end_date

    errors.add(:end_date, 'No se puede registrar una fecha anterior al último registro.')
  end
end
