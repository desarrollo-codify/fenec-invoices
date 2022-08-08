class DailyCode < ApplicationRecord
  validates :code, presence: true
  validates :date, presence: true, uniqueness: { scope: :branch_office_id,
    message: "only one daily code per branch office" }

  belongs_to :branch_office
end
