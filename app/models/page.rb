class Page < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }

  belongs_to :system_module
end
