class SystemModule < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }
end
