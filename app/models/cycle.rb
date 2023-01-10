# frozen_string_literal: true

class Cycle < ApplicationRecord
  validates :start_date, presence: { message: 'La fecha de inicio no puede estar en blanco.' }
  validates :end_date, presence: { message: 'La fecha no puede estar en blanco.' }
  validates :status, presence: { message: 'El estado no puede estar en blanco.' }

  scope :open, -> { where(status: 'ABIERTA') }

  def self.current
    open.last
  end

  has_many :periods
  belongs_to :company
end
