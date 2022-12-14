# frozen_string_literal: true

class InvoiceDetail < ApplicationRecord
  validates :economic_activity_code, presence: { message: 'La actividad económica no puede estar en blanco.' }
  validates :product_code, presence: { message: 'El código del producto no puede estar en blanco.' }
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }
  validates :quantity, presence: { message: 'La cantidad no puede estar en blanco.' },
                       numericality: { greater_than_or_equal_to: 0, message: 'Cantidad debe ser mayor o igual a 0.' }
  validates :unit_price, presence: { message: 'El precio unitario no puede estar en blanco.' },
                         numericality: { greater_than_or_equal_to: 0, message: 'Precio unitario debe ser mayor o igual a 0.' }
  validates :subtotal, presence: { message: 'El subtotal no puede estar en blanco.' },
                       numericality: { greater_than_or_equal_to: 0, message: 'Subtotal debe ser mayor o igual a 0.' }
  validates :discount, presence: { message: 'El descuento no puede estar en blanco.' },
                       numericality: { greater_than_or_equal_to: 0, message: 'Descuento debe ser mayor o igual a 0.' }
  validates :total, presence: { message: 'El total no puede estar en blanco.' },
                    numericality: { greater_than_or_equal_to: 0, message: 'Total debe ser mayor o igual a 0.' }

  validate :discount_cannot_be_greater_or_equal_than_subtotal
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

  def discount_cannot_be_greater_or_equal_than_subtotal
    errors.add(:discount, 'Descuento no puede ser mayor al subtotal') if discount && subtotal && discount >= subtotal
  end

  def subtotal_must_be_correctly_calculated
    return if subtotal && quantity && unit_price && subtotal.round(2) == unit_price.round(2) * quantity

    errors.add(:subtotal, 'El subtotal no esta calculado correctamente.')
  end

  def total_must_be_correctly_calculated
    return if subtotal && discount && total.round(2) == subtotal.round(2) - discount.round(2)

    errors.add(:total,
               'El total no esta calculado correctamente.')
  end
end
