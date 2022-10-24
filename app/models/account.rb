class Account < ApplicationRecord
  belongs_to :company
  belongs_to :cycle
  belongs_to :account_type
  belongs_to :account_level
end
