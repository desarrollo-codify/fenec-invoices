# frozen_string_literal: true

class TransactionNumber < ApplicationRecord
  belongs_to :cycle
  belongs_to :transaction_type

  after_initialize :default_values

  def increment!
    self.number += 1
    save!
  end

  private

  def default_values
    self.number ||= 1
  end
end
