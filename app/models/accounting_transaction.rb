# frozen_string_literal: true

class AccountingTransaction < ApplicationRecord
  belongs_to :currency
  belongs_to :cycle
  belongs_to :company
  belongs_to :transaction_type

  has_many :entries, dependent: :destroy
  accepts_nested_attributes_for :entries, reject_if: :all_blank
end
