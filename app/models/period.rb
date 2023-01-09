# frozen_string_literal: true

class Period < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }
  validates :start_date, presence: { message: 'La fecha de inicio no puede estar en blanco.' }, uniqueness: true
  validates :status, presence: { message: 'El estado no puede estar en blanco.' }

  belongs_to :cycle

  after_initialize :default_values

  scope :open, -> { where(status: 'ABIERTO') }

  def self.current
    open.last
  end

  private

  def default_values
    return unless new_record?

    self.status ||= 'ABIERTO'
  end
end
