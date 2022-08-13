# frozen_string_literal: true

class InvoiceStatus < ApplicationRecord
  validates :description, presence: true
end
