# frozen_string_literal: true

class DelegatedToken < ApplicationRecord
  validates :token, presence: true, uniqueness: { scope: :company_id,
                                                  message: 'No se puede registrar un token duplicado.' }
  validates :expiration_date, presence: true

  belongs_to :company
end
