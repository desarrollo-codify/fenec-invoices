# frozen_string_literal: true

class SenderEmail < ApplicationRecord
  validates :address, presence: true
  validates :port, presence: true, numericality: { only_integer: true, message: 'El Puerto debe ser un valor numérico.' }
  validates :domain, presence: true
  validates :user_name, presence: true, length: { maximum: 105 }, format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true

  belongs_to :company
end
