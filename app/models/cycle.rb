# frozen_string_literal: true

class Cycle < ApplicationRecord
  scope :current, -> { where(status: 'ABIERTA').last }
  belongs_to :company
end
