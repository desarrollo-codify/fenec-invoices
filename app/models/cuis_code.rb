# frozen_string_literal: true

class CuisCode < ApplicationRecord
  validates :code, presence: true, uniqueness: { scope: :branch_office_id,
                                                 message: 'Solo puede haber un CUIS por sucursal.' }
  validates :expiration_date, presence: true
  validates :current_number, presence: true

  belongs_to :branch_office

  after_initialize :default_values

  def increment!
    self.current_number += 1
    save!
  end

  private

  def default_values
    self.current_number ||= 0
  end
end
