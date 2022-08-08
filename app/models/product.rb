class Product < ApplicationRecord
  validates :primary_code, presence: true, presence: true, uniqueness: { scope: :company_id,
    message: "only one primary code per company" }
  validates :description, presence: true

  belongs_to :company
end
