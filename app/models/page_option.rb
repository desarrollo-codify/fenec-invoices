# frozen_string_literal: true

class PageOption < ApplicationRecord
  validates :code, presence: { message: 'La descripción no puede estar en blanco.' }
  validates :description, presence: { message: 'El código no puede estar en blanco.' }

  belongs_to :page
  has_and_belongs_to_many :users
end
