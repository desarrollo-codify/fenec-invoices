# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name, presence: true, uniqueness: true, format: { with: VALID_NAME_REGEX }
  validates :nit, presence: true, numericality: { only_integer: true, message: 'El NIT debe ser un valor numérico.' }
  validates :address, presence: true

  has_many :branch_offices, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :invoices, through: :branch_offices
  has_many :clients, dependent: :destroy
  has_many :delegated_tokens, dependent: :destroy
end
