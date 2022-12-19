# frozen_string_literal: true

class Cycle < ApplicationRecord
  scope :open, -> { where(status: 'ABIERTA') }

  def self.current
    open.last
  end

  belongs_to :company
end
