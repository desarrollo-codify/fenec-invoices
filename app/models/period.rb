# frozen_string_literal: true

class Period < ApplicationRecord
  validates :description, presence: { message: 'La descripción no puede estar en blanco.' }
  validates :start_date, presence: { message: 'La fecha de inicio no puede estar en blanco.' }
  validates :status, presence: { message: 'El estado no puede estar en blanco.' }

  belongs_to :cycle
  has_many :transaction_number, dependent: :destroy

  after_initialize :default_values

  scope :open, -> { where(status: 'ABIERTO') }

  def self.current
    open.last
  end

  def open?
    return true if status == 'ABIERTO'

    false
  end

  private

  def default_values
    return unless new_record?

    self.status ||= 'ABIERTO'
  end
end
