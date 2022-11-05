# frozen_string_literal: true

class AccountingTransaction < ApplicationRecord
  validates :date, presence: true
  validates :gloss, presence: true

  validate :has_at_least_two_entries
  validate :debit_and_credit_equal_sum

  belongs_to :currency
  belongs_to :cycle
  belongs_to :company
  belongs_to :transaction_type

  has_many :entries, dependent: :destroy
  accepts_nested_attributes_for :entries, reject_if: :all_blank

  private

  def has_at_least_two_entries
    errors.add(:entries, 'Se deben agregar un mínimo de dos asientos.') unless entries.length >= 2
  end

  def debit_and_credit_equal_sum
    sum_debit = 0
    sum_credit = 0
    entries.each do |entry|
      sum_debit += entry.debit_bs if entry.debit_bs.present?
      sum_credit += entry.credit_bs if entry.credit_bs.present?
    end
    errors.add(:entries, 'La suma de debito y credito debe ser igual.') unless sum_debit == sum_credit
  end
end
