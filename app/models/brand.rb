# frozen_string_literal: true

class Brand < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }
end
