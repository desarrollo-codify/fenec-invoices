# frozen_string_literal: true

class InvoiceDetail < ApplicationRecord
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }
  validates :unit_price, presence: true,
                         numericality: { greater_than_or_equal_to: 0, message: 'Precio unitario debe ser mayor o igual a 0.' }
  validates :quantity, presence: true,
                       numericality: { greater_than_or_equal_to: 0, message: 'Cantidad debe ser mayor o igual a 0.' }
  validates :subtotal, presence: true,
                       numericality: { greater_than_or_equal_to: 0, message: 'Subtotal debe ser mayor o igual a 0.' }
  validates :discount, presence: true,
                       numericality: { greater_than_or_equal_to: 0, message: 'Descuento debe ser mayor o igual a 0.' }
  validates :total, presence: true,
                    numericality: { greater_than_or_equal_to: 0, message: 'Total debe ser mayor o igual a 0.' }
  validate :discount_cannot_be_greater_than_subtotal
  validate :subtotal_must_be_correctly_calculated
  validate :total_must_be_correctly_calculated

  belongs_to :product
  belongs_to :measurement
  belongs_to :invoice

  after_initialize :default_values

  private

  def default_values
    self.discount ||= 0.00
    self.quantity ||= 1
  end

  def discount_cannot_be_greater_than_subtotal
    errors.add(:discount, 'Descuento no puede ser mayor al subtotal') if discount && subtotal && discount > subtotal
  end

  def subtotal_must_be_correctly_calculated
    return if subtotal && quantity && unit_price && subtotal == unit_price * quantity

    errors.add(:subtotal, 'El subtotal no esta calculado correctamente.')
  end

  def total_must_be_correctly_calculated
    errors.add(:total, 'El total no esta calculado correctamente.') unless subtotal && discount && total == subtotal - discount
  end
end
