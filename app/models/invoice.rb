# frozen_string_literal: true

class Invoice < ApplicationRecord
  validates :company_nit, presence: true
  validates :company_name, presence: true
  validates :municipality, presence: true, format: { with: VALID_NAME_REGEX }
  validates :number,
            uniqueness: { scope: :cufd_code,
                          message: 'Ya existe este número de factura con el código único de facturación diaria.',
                          unless: -> { number.blank? } }
  validates :cufd_code, presence: true
  validates :address, presence: true
  validates :date, presence: true
  validates :business_name, presence: true
  validates :document_type, presence: true
  validates :business_nit, presence: true
  validates :client_code, presence: true
  validates :payment_method, presence: true
  validates :total, presence: true,
                    numericality: { message: 'El total debe ser un valor numérico.' }
  validates :currency_code, presence: true
  validates :exchange_rate, presence: true
  validates :currency_total, presence: true
  validates :legend, presence: true
  validates :user, presence: true
  validates :document_sector_code, presence: true

  validates :subtotal, presence: true,
                       numericality: { message: 'El subtotal debe ser un valor numérico.' }
  validate :discount_cannot_be_greater_or_equal_than_subtotal
  validate :total_must_be_correctly_calculated
  validate :total_paid_must_be_equal_to_total
  validate :business_nit_is_ci_or_nit

  belongs_to :branch_office
  belongs_to :invoice_status
  has_many :invoice_details, dependent: :destroy # , inverse_of: :invoice
  has_one :cancellation_reason
  has_and_belongs_to_many :payment_methods
  accepts_nested_attributes_for :invoice_details, reject_if: :all_blank

  scope :for_sending, -> { where(sent_at: nil) }
  scope :by_cufd, ->(cufd) { for_sending.where(cufd_code: cufd) }
  scope :descending, -> { order(date: :desc) }

  after_initialize :default_values

  def validate!
    # - valid CUIS?
    # - valid CUFD?
    # - Are there economic activities for the branch office?
    # - Is there a product for each invoice detail?
    # - Are there document types?
    # - Are there measurements?
    # - Are there invoice statuses?
    # - Are there payment methods?
    # - Are there legends for the economic activity?
  end

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

  def discount_cannot_be_greater_or_equal_than_subtotal
    errors.add(:discount, 'Descuento no puede ser mayor al subtotal.') if discount && subtotal && discount >= subtotal
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

  def business_nit_is_ci_or_nit
    return if (document_type == 5 || document_type == 1) && business_nit.present? && business_nit.scan(/\D/).empty?

    errors.add(:business_nit,
               'El número de documento debe ser numérico.')
  end
end
