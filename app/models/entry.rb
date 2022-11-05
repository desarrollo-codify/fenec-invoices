# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :accounting_transaction
  belongs_to :account

  after_initialize :default_values, if: :new_record?

  private

  def default_values
    self.debit_bs ||= 0
    self.credit_bs ||= 0
    self.debit_sus ||= 0
    self.credit_sus ||= 0
  end
end
