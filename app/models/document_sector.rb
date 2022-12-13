# frozen_string_literal: true

class DocumentSector < ApplicationRecord
  validates :code, presence: { message: 'El código no puede estar en blanco.' }
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }

  belongs_to :economic_activity
end
