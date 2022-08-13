class DailyCode < ApplicationRecord
  validates :code, presence: true
  validates :effective_date, presence: true, uniqueness: { scope: :branch_office_id,
    message: 'Solo puede ser un codigo diario por sucursal.' }

  belongs_to :branch_office
end
