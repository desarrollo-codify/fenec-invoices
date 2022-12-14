# frozen_string_literal: true

class AccountingTransaction < ApplicationRecord
  validates :date, presence: { message: 'La fecha no puede estar en blanco.' }
  validates :gloss, presence: { message: 'La glosa no puede estar en blanco.' }

  validate :at_least_two_entries?
  validate :debit_and_credit_must_be_equal_and_greater_than_zero

  belongs_to :currency
  belongs_to :cycle
  belongs_to :company
  belongs_to :transaction_type

  has_many :entries, dependent: :destroy
  accepts_nested_attributes_for :entries, reject_if: :all_blank

  private

  def at_least_two_entries?
    errors.add(:entries, 'Se deben agregar un mínimo de dos asientos.') unless entries.length >= 2
  end

  def debit_and_credit_must_be_equal_and_greater_than_zero
    sum_debit = entries.inject(0) { |total, entry| total + entry.debit_bs }
    sum_credit = entries.inject(0) { |total, entry| total + entry.credit_bs }
    errors.add(:entries, 'La suma de debito y credito debe ser igual.') unless sum_debit == sum_credit
    errors.add(:entries, 'El monto en debito debe ser mayor a 0.') unless sum_debit.positive?
    errors.add(:entries, 'El monto en credito debe ser mayor a 0.') unless sum_credit.positive?
  end
end
