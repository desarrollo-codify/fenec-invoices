class BranchOffice < ApplicationRecord
  validates :name, presence: true
  validates :number, presence: true, uniqueness: { scope: :company_id,
    message: "only one branch office number per company" }

  belongs_to :company
end
