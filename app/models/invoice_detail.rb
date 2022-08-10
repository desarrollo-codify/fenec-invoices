class InvoiceDetail < ApplicationRecord
  belongs_to :measurement
  belongs_to :product
  belongs_to :invoice
end
