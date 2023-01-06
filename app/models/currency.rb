# frozen_string_literal: true

class Currency < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }
  validates :abbreviation, presence: { message: 'La abreviación no puede estar en blanco.' }
end
