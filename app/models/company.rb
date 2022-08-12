class Company < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :nit, presence: true, numericality: { only_integer: true, message: "El NIT debe ser un valor numérico." }
  validates :address, presence: true

  has_many :branch_offices, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :invoices, through: :branch_offices
  has_many :clients, dependent: :destroy
end
