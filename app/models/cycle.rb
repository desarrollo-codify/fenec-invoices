# frozen_string_literal: true

class Cycle < ApplicationRecord
  scope :open, -> { where(status: 'ABIERTA') }

  has_many :transaction_number, dependent: :destroy

  def self.current
    open.last
  end

  belongs_to :company
end
