# frozen_string_literal: true

class Page < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }

  has_many :page_options, dependent: :destroy
  belongs_to :system_module
end
