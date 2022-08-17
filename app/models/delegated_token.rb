# frozen_string_literal: true

class DelegatedToken < ApplicationRecord
  validates :token, presence: true, uniqueness: { scope: :company_id,
    message: 'Solo puede ser una key por empresa.' }
  validates :expiration_date, presence: true

  belongs_to :company
end
