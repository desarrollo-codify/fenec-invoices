class Client < ApplicationRecord
  validates :name, presence: true
  validates :nit, presence: true, numericality: { only_integer: true, message: "El NIT debe ser un valor numérico." }

  belongs_to :company
end
