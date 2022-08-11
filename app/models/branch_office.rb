class BranchOffice < ApplicationRecord
  validates :name, presence: true
  validates :city, presence: true
  validates :number, presence: true, uniqueness: { scope: :company_id,
    message: "only one branch office number per company" }

  belongs_to :company
  has_many :daily_codes, dependent: :destroy
  has_many :invoices
end
