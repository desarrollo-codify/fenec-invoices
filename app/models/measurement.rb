# frozen_string_literal: true

class Measurement < ApplicationRecord
  validates :description, presence: true
end
