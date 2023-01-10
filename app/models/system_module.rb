# frozen_string_literal: true

class SystemModule < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }

  has_many :pages, dependent: :destroy
end
