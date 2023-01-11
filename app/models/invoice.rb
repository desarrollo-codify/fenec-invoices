# frozen_string_literal: true

class Invoice < ApplicationRecord
  validates :company_nit, presence: { message: 'El nit de la empresa no puede estar en blanco.' }
  validates :company_name, presence: { message: 'El nombre de la empresa no puede estar en blanco.' }
  validates :municipality, presence: { message: 'La municipalidad no puede estar en blanco.' }, format: { with: VALID_NAME_REGEX }
  validates :number,
            uniqueness: { scope: :cufd_code,
                          message: 'Ya existe este número de factura con el código único de facturación diaria.',
                          unless: -> { number.blank? } }
  validates :cufd_code, presence: { message: 'El código CUFD no puede estar en blanco.' }
  validates :address, presence: { message: 'La dirección no puede estar en blanco.' }
  validates :date, presence: { message: 'La fecha no puede estar en blanco.' }
  validates :business_name, presence: { message: 'El nombre o razón social no puede estar en blanco.' }
  validates :document_type, presence: { message: 'El tipo de documento no puede estar en blanco.' }
  validates :business_nit, presence: { message: 'El nit a emitir no puede estar en blanco.' }
  validates :client_code, presence: { message: 'El código del cliente no puede estar en blanco.' }
  validates :payment_method, presence: { message: 'El método de pago no puede estar en blanco.' }
  validates :total, presence: { message: 'El total no puede estar en blanco.' },
                    numericality: { message: 'El total debe ser un valor numérico.' }
  validates :currency_code, presence: { message: 'El código de moneda no puede estar en blanco.' }
  validates :exchange_rate, presence: { message: 'El tipod e cambio no puede estar en blanco.' }
  validates :currency_total, presence: { message: 'El monto en moneda nacional total no puede estar en blanco.' }
  validates :legend, presence: { message: 'La leyenda no puede estar en blanco.' }
  validates :user, presence: { message: 'El código de usuario no puede estar en blanco.' }
  validates :document_sector_code, presence: { message: 'El código de documento sector no puede estar en blanco.' }

  validates :subtotal, presence: { message: 'El subtotal no puede estar en blanco.' },
                       numericality: { message: 'El subtotal debe ser un valor numérico.' }

  validate :discount_cannot_be_greater_or_equal_than_subtotal
  validate :total_must_be_correctly_calculated
  validate :total_paid_must_be_equal_to_total
  validate :business_nit_is_ci_or_nit
  validate :amount_payable_must_be_correctly_calculated

  belongs_to :branch_office
  belongs_to :invoice_status
  belongs_to :contingency, optional: true
  has_many :invoice_details, dependent: :destroy # , inverse_of: :invoice
  has_many :invoice_logs, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_one :cancellation_reason
  has_one :order, dependent: :destroy
  has_and_belongs_to_many :payment_methods
  accepts_nested_attributes_for :invoice_details, reject_if: :all_blank

  scope :for_sending, -> { where(sent_at: nil) }
  scope :by_cufd, ->(cufd) { for_sending.where(cufd_code: cufd) }
  scope :descending, -> { order(date: :desc) }
  scope :for_sending_cancel, -> { where.not(cancellation_reason_id: nil).where(cancel_sent_at: nil) }
  scope :by_point_of_sale, ->(pos) { where(point_of_sale: pos) }

  after_initialize :default_values

  private

  def default_values
    self.discount ||= 0.00
    self.gift_card_total ||= 0.00
    self.advance ||= 0.00
    self.amount_payable ||= 0.00
    self.business_name ||= 'S/N'
    self.business_nit ||= '0'
  end

  def discount_cannot_be_greater_or_equal_than_subtotal
    errors.add(:discount, 'Descuento no puede ser mayor al subtotal.') if discount && subtotal && discount >= subtotal
  end

  def total_must_be_correctly_calculated
    return if total && discount && subtotal && discount && gift_card_total && advance && total.round(2) == (subtotal - discount - advance).round(2)

    errors.add(:total, 'El monto total no concuerda con el calculo realizado.')
  end

  def amount_payable_must_be_correctly_calculated
    return unless total
    return if amount_payable && gift_card_total && amount_payable == (total - gift_card_total).round(2)

    errors.add(:amount_payable, 'El monto a pagar debe ser igual al total de la factura menos el monto del gift card, si existe.')
  end

  def total_paid_must_be_equal_to_total
    sum_payment = payments.inject(0) { |total, payment| total + payment.mount.round(2) }

    errors.add(:total, 'El total pagado no concuerda con el total a pagar.') unless sum_payment + gift_card_total == total
  end

  def business_nit_is_ci_or_nit
    return unless document_type == 5 || document_type == 1

    return unless business_nit.present? && business_nit.scan(/\D/).any?

    errors.add(:business_nit, 'El número de documento debe ser numérico.')
  end
end
