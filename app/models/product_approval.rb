# frozen_string_literal: true

class ProductApproval < ApplicationRecord
  validates :code, presence: true
  validates :description, presence: true

  belongs_to :economic_activity
end
