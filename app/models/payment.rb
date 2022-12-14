# frozen_string_literal: true

class Payment < ApplicationRecord
  validates :mount, presence: true

  belongs_to :payment_method
  belongs_to :invoice
end
