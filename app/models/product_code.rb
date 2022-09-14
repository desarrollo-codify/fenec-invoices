# frozen_string_literal: true

class ProductCode < ApplicationRecord
  validates :code, presence: true
  validates :description, presence: true, format: { with: VALID_NAME_REGEX }

  belongs_to :economic_activity
end
