# frozen_string_literal: true

class DelegatedToken < ApplicationRecord
  validates :token, presence: { message: 'El token no puede estar en blanco.' }, uniqueness: { scope: :company_id,
                                                  message: 'Solo puede existir un token delegado por empresa.' }
  validates :expiration_date, presence: { message: 'La fecha de caducidad no puede estar en blanco.' }

  belongs_to :company
end
