# frozen_string_literal: true

class Variant < ApplicationRecord
  validates :title, presence: { message: 'El título no puede estar en blanco.' }

  belongs_to :product
end
