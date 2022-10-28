# frozen_string_literal: true

class Product < ApplicationRecord
  validates :primary_code, presence: true, uniqueness: { scope: :company_id,
                                                         message: 'Ya existe este codigo primario de producto.' }
  validates :description, presence: true

  belongs_to :company
  belongs_to :product_type, optional: true
  belongs_to :product_category, optional: true
  belongs_to :product_status, optional: true
  belongs_to :brand, optional: true
  has_many :variants, dependent: :destroy
end
