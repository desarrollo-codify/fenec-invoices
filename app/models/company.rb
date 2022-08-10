class Company < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :nit, presence: true
  validates :address, presence: true

  has_many :branch_offices, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :invoices, through: :branch_offices
  has_many :clients, dependent: :destroy
end
