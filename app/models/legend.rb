# frozen_string_literal: true

class Legend < ApplicationRecord
  validates :code, presence: { message: 'El código no puede estar en blanco.' }
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }, format: { with: VALID_NAME_REGEX }

  belongs_to :economic_activity

  def random
    order(Arel.sql('RANDOM()')).first
  end
end
