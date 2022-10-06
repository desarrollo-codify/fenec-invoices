# frozen_string_literal: true

class PointOfSale < ApplicationRecord
  validates :code, uniqueness: { scope: :branch_office_id, unless: -> { code.blank? },
                                 message: 'Ya existe este codigo de punto de venta para esta sucursal.' }
  validates :name, presence: true, format: { with: VALID_NAME_REGEX, unless: -> { name.blank? } }

  belongs_to :branch_office
  has_many :contingencies, dependent: :destroy
end
