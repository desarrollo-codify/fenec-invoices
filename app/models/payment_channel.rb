class PaymentChannel < ApplicationRecord
  validates :description, presence: true
end
