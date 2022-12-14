# frozen_string_literal: true

class PageSize < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }
end
