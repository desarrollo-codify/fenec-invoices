# frozen_string_literal: true

class TransactionType < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }

  has_many :transaction_numbers, dependent: :destroy
end
