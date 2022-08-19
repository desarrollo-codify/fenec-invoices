# frozen_string_literal: true

class EconomicActivity < ApplicationRecord
  validates :code, presence: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  belongs_to :company
end
