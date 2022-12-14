# frozen_string_literal: true

class Modality < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }, format: { with: VALID_NAME_REGEX }

  has_many :companies
end
