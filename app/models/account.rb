# frozen_string_literal: true

class Account < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }, 
  validates :number, presence: { message: 'El número no puede estar en blanco.' }

  belongs_to :company
  belongs_to :cycle
  belongs_to :account_type
  belongs_to :account_level
end
