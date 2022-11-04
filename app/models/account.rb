# frozen_string_literal: true

class Account < ApplicationRecord
  validates :description, presence: true
  validates :number, presence: true

  belongs_to :company
  belongs_to :cycle
  belongs_to :account_type
  belongs_to :account_level
end
