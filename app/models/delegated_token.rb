# frozen_string_literal: true

class DelegatedToken < ApplicationRecord
  validates :token, presence: true, uniqueness: true
  validates :expiration_date, presence: true

  belongs_to :company
end
