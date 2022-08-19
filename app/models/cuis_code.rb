# frozen_string_literal: true

class CuisCode < ApplicationRecord
  validates :code, presence: true, uniqueness: { scope: :branch_office_id,
                                                 message: 'Solo puede haber un CUIS por sucursal.' }
  validates :expiration_date, presence: true

  belongs_to :branch_office
end
