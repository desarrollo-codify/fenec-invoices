# frozen_string_literal: true

class ProductType < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }
end
