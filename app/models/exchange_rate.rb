# frozen_string_literal: true

class ExchangeRate < ApplicationRecord
  validates :date, presence: { message: 'La fecha no puede estar en blanco.' },
                   uniqueness: { scope: :company_id,
                                 message: 'Solo puede haber un tipo de cambio por fecha.' }
  validates :rate, presence: { message: 'El tipo de cambio no puede estar en blanco.' },
                   numericality: { greater_than: 0, message: 'Tipo de Cambio debe ser mayor a 0.' }

  belongs_to :company

  scope :search, ->(date) { where('date >= ?', date) }

  def self.by_date(date)
    search(date).first
  end
end
