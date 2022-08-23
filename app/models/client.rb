# frozen_string_literal: true

class Client < ApplicationRecord
  validates :name, presence: true, format: { with: VALID_NAME_REGEX }
  validates :nit, presence: true, numericality: { only_integer: true, message: 'El NIT debe ser un valor numérico.' }
  validates :email, format: { with: VALID_EMAIL_REGEX }

  belongs_to :company
end
