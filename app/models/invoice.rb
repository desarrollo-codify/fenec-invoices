class Invoice < ApplicationRecord
  validates :business_name, presence: true
  validates :date, presence: true
  validates :business_nit, presence: true, numericality: { only_integer: true, message: "El NIT debe ser un valor numérico." }
  validates :number, uniqueness: { scope: :cufd_code, message: "Ya existe este número de factura con el código único de facturación diaria."}
  validates :subtotal, presence: true, numericality: { only_integer: true, message: "El subtotal debe ser un valor numérico." }
  validates :total, presence: true, numericality: { only_integer: true, message: "El total debe ser un valor numérico." }

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
    self.business_name ||= "S/N"
    self.business_nit ||= "0"
  end
end
