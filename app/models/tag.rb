# frozen_string_literal: true

class Tag < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }

  belongs_to :taggable, polymorphic: true
end
