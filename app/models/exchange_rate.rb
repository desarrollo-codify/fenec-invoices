# frozen_string_literal: true

class ExchangeRate < ApplicationRecord
  validates :date, presence: true, uniqueness: { scope: :company_id,
                                                 message: 'Solo puede haber un tipo de cambio por fecha.' }
  validates :rate, presence: true,
                   numericality: { greater_than: 0, message: 'Tipo de Cambio debe ser mayor a 0.' }

  belongs_to :company
end
