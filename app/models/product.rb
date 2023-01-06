# frozen_string_literal: true

class Product < ApplicationRecord
  validates :primary_code, presence: { message: 'El código primario no puede estar en blanco.' },
                           uniqueness: { scope: :company_id,
                                         message: 'Ya existe este codigo primario de producto.' }
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }

  belongs_to :company
  belongs_to :product_type, optional: true
  belongs_to :product_category, optional: true
  belongs_to :product_status, optional: true
  belongs_to :brand, optional: true
  has_many :variants, dependent: :destroy
  belongs_to :measurement, optional: true
  has_many :tags, as: :taggable
end
