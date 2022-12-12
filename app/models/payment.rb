# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :payment_method
  belongs_to :invoice
end
