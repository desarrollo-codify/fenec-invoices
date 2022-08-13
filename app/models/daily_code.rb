class DailyCode < ApplicationRecord
  validates :code, presence: true
  validates :effective_date, presence: true, uniqueness: { scope: :branch_office_id,
    message: 'Solo puede ser un codigo diario por sucursal.' }
  validate :date_cannot_be_lower_than_last_one

  belongs_to :branch_office

  private 

  def date_cannot_be_lower_than_last_one
    last_daily_code = DailyCode.where(branch_office_id: branch_office_id).last
    if last_daily_code
      errors.add(:effective_date, "No se puede registrar una fecha anterior al último registro.") if effective_date < last_daily_code.effective_date
    end
  end
end
