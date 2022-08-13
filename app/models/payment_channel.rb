# frozen_string_literal: true

class PaymentChannel < ApplicationRecord
  validates :description, presence: true
end
