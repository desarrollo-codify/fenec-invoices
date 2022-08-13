# frozen_string_literal: true

class Invoice < ApplicationRecord
  validates :business_name, presence: true, format: { with: VALID_NAME_REGEX }
  validates :company_name, format: { with: VALID_NAME_REGEX }
  validates :date, presence: true
  validates :business_nit, presence: true,
                           numericality: { only_integer: true, message: 'El NIT debe ser un valor numérico.' }
  validates :number,
            uniqueness: { scope: :cufd_code,
                          message: 'Ya existe este número de factura con el código único de facturación diaria.' }
  validates :subtotal, presence: true,
                       numericality: { only_integer: true, message: 'El subtotal debe ser un valor numérico.' }
  validates :total, presence: true,
                    numericality: { only_integer: true, message: 'El total debe ser un valor numérico.' }
  validate :discount_cannot_be_greater_than_subtotal
  validate :total_must_be_correctly_calculated
  validate :total_paid_must_be_equal_to_total

  belongs_to :branch_office
  belongs_to :invoice_status
  has_many :invoice_details, dependent: :destroy # , inverse_of: :invoice

  after_initialize :default_values

  private

  def default_values
    self.discount ||= 0.00
    self.gift_card ||= 0.00
    self.advance ||= 0.00
    self.cash_paid ||= 0.00
    self.online_paid ||= 0.00
    self.qr_paid ||= 0.00
    self.card_paid ||= 0.00
    self.business_name ||= 'S/N'
    self.business_nit ||= '0'
  end

  def discount_cannot_be_greater_than_subtotal
    errors.add(:discount, 'Descuento no puede ser mayor al subtotal.') if discount && subtotal && discount > subtotal
  end

  def total_must_be_correctly_calculated
    if total && discount && subtotal && discount && gift_card && advance && (total == subtotal - discount - gift_card - advance)
      return
    end

    errors.add(:total, 'El monto total no concuerda con el calculo realizado.')
  end

  def total_paid_must_be_equal_to_total
    return if total && qr_paid && cash_paid && card_paid && total == qr_paid + cash_paid + card_paid

    errors.add(:total, 'El total pagado no concuerda con el total a pagar.')
  end
end
