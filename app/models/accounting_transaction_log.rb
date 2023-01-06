# frozen_string_literal: true

class AccountingTransactionLog < ApplicationRecord
  validates :full_name, presence: true
  validates :action, presence: true
  validates :log_action, presence: true

  belongs_to :accounting_transaction
end
