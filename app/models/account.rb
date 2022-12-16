# frozen_string_literal: true

class Account < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }
  validates :number, presence: { message: 'El número no puede estar en blanco.' }

  scope :for_transactions, ->(level, cycle) { where(account_level_id: level, cycle_id: cycle) }

  belongs_to :company
  belongs_to :cycle
  belongs_to :account_type
  belongs_to :account_level
end
