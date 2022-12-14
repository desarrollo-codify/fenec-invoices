# frozen_string_literal: true

class CuisCode < ApplicationRecord
  validates :code, presence: { message: 'El código no puede estar en blanco.' }, uniqueness: { scope: :branch_office_id,
                                                 message: 'Solo puede haber un CUIS por sucursal.' }
  validates :expiration_date, presence: { message: 'La fecha de caducidad no puede estar en blanco.' }
  validates :current_number, presence: { message: 'El número actual no puede estar en blanco.' }

  belongs_to :branch_office

  after_initialize :default_values

  scope :active, -> { where('expiration_date >= ?', DateTime.now) }
  scope :by_pos, ->(point_of_sale) { where(point_of_sale: point_of_sale) }

  def self.current
    active.last
  end

  def increment!
    self.current_number += 1
    save!
  end

  private

  def default_values
    self.current_number ||= 1
  end
end
