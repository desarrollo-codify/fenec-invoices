class InvoiceStatus < ApplicationRecord
  validates :description, presence: true
end
