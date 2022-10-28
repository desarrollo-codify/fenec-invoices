# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :accounting_transaction
  belongs_to :account
end
