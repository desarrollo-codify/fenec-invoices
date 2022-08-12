class InvoiceDetail < ApplicationRecord
  validates :description, presence: true
  validates :unit_price, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0, message: "Cantidad debe ser mayor o igual a 0." }
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0, message: "Subtotal debe ser mayor o igual a 0." }
  validates :discount, presence: true, numericality: { greater_than_or_equal_to: 0, message: "Descuento debe ser mayor o igual a 0." }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0, message: "Total debe ser mayor o igual a 0." }
  
  belongs_to :measurement
  belongs_to :product
  belongs_to :invoice

  after_initialize :default_values

  private

  def default_values
    self.discount ||= 0.00
    self.quantity ||= 1
  end
end
