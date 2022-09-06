# frozen_string_literal: true

class PointOfSale < ApplicationRecord
  validates :number, presence: true, uniqueness: { scope: :branch_office_id,
                                                   message: 'Ya existe este numero de punto de venta para esta sucursal.' }
  validates :code, uniqueness: { scope: :branch_office_id, unless: -> { code.blank? },
                                 message: 'Ya existe este codigo de punto de venta para esta sucursal.' }
  validates :name, format: { with: VALID_NAME_REGEX, unless: -> { name.blank? } }

  belongs_to :branch_office
end
