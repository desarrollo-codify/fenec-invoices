class Product < ApplicationRecord
  validates :primary_code, presence: true, uniqueness: { scope: :company_id,
    message: "Ya existe este codigo primario de producto." }
  validates :description, presence: true

  belongs_to :company
end
