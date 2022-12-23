# frozen_string_literal: true

class AccountingTransactionLog < ApplicationRecord
  belongs_to :accounting_transaction
end
