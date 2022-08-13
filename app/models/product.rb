# frozen_string_literal: true

class Product < ApplicationRecord
  validates :primary_code, presence: true, uniqueness: { scope: :company_id,
                                                         message: 'Ya existe este codigo primario de producto.' }
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  belongs_to :company
end
