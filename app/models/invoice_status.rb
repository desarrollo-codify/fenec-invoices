# frozen_string_literal: true

class InvoiceStatus < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }
end
