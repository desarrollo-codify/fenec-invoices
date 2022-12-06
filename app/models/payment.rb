class Payment < ApplicationRecord
  belongs_to :payment_methods
  belongs_to :invoices
end
