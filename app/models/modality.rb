# frozen_string_literal: true

class Modality < ApplicationRecord
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  has_many :companies
end
