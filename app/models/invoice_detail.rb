class InvoiceDetail < ApplicationRecord
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
