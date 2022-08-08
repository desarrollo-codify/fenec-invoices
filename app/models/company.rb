class Company < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :nit, presence: true
  validates :address, presence: true

  has_many :branch_offices, dependent: :destroy
end
